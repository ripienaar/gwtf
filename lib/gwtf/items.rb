module Gwtf
  class Items
    def self.config_file(data_dir)
      File.expand_path(File.join(data_dir, "..", "gwtf.json"))
    end

    def self.setup(data_dir)
      require 'fileutils'

      raise "#{data_dir} already exist" if File.exist?(data_dir)

      FileUtils.mkdir_p(File.join(data_dir, "backups"))
      FileUtils.mkdir_p(File.join(data_dir, "archive"))
      FileUtils.mkdir_p(File.join(data_dir, "garbage"))

      unless File.exist?(config_file(data_dir))
        File.open(config_file(data_dir), "w") do |f|
          f.print({"next_item" => 0}.to_json)
        end
      end
    end

    # overview text of open (or all) items in all projects
    def self.overview_text(datadir, all=false)
      overview = StringIO.new

      Gwtf.projects(datadir).each do |project|
        next if project == "reminders"

        items = Gwtf::Items.new(File.join(datadir, project), project)

        if items.item_ids.size > 0
          if text = items.list_text(all, true)
            overview.puts text
            overview.puts
          end
        end
      end

      overview.string
    end

    # overview text of all due items in all projects
    def self.due_text(datadir)
      overview = StringIO.new

      Gwtf.projects(datadir).each do |project|
        next if project == "reminders"

        items = Gwtf::Items.new(File.join(datadir, project), project)

        items.each_item do |item|
          overview.puts "%s: %s" % [ project, item.to_s ] if item.due?
        end
      end

      overview.string
    end

    def initialize(data_dir, project)
      raise "Data directory #{data_dir} does not exist" unless File.directory?(data_dir)

      @project = project
      @data_dir = data_dir
      @config = read_config
    end

    # Creates a new blank item with the next available ID, saves it and saves
    # the global config with the next id that should be assigned
    def new_item
      item = Item.new(nil, @project)
      item.item_id = @config["next_item"]
      item.file = File.join(@data_dir, "#{item.item_id}.gwtf")

      @config["next_item"] += 1
      save_config

      item
    end

    # Loads an item from disk
    def load_item(item)
      raise "Item #{item} does not exist" unless File.exist?(file_for_item(item))

      Item.new(file_for_item(item), @project)
    end

    # Reads the overall gwtf config file
    def read_config
      JSON.parse(File.read(Items.config_file(@data_dir)))
    end

    # Saves the overall gwtf config
    def save_config
      raise "Config has not been loaded" unless @config

      File.open(Items.config_file(@data_dir), "w") do |f|
        f.print(@config.to_json)
      end
    end

    # Array of integer IDs that belong to this project in ascending order
    def item_ids
      Dir.entries(@data_dir).grep(/\.gwtf$/).map{|i| File.basename(i, ".gwtf")}.map{|i| Integer(i)}.sort
    end

    # Returns the path where the JSON data for a item might be found in the current project
    def file_for_item(item)
      File.join(@data_dir, "#{item}.gwtf")
    end

    # Iterates over all items in a project
    def each_item
      item_ids.each {|item| yield load_item(item) }
    end

    # Returns an array of total, open and closed items for the current project
    def stats
      count = {"open" => 0, "closed" => 0, "overdue" => 0, "due_soon" => 0, "due_today" => 0}

      each_item do |item|
        count[ item.status ] += 1

        count["overdue"] += 1 if item.overdue?
        count["due_soon"] += 1 if item.days_till_due == 1
        count["due_today"] += 1 if item.days_till_due == 0
      end

      count["total"] = count["open"] + count["closed"]

      count
    end

    # Returns a blob of text that represents a list of items in a project
    def list_text(all=false, only_if_active=false)
      list = StringIO.new
      items = StringIO.new

      count = {"open" => 0, "closed" => 0}

      each_item do |item|
        count[ item[:status] ] += 1

        items.puts item.to_s if (all || item.open?)
      end

      count["total"] = count["open"] + count["closed"]

      return nil if only_if_active && count["open"] == 0

      list.puts "Project %s items: %d / %d" % [ @project, count["open"], count["total"] ]
      list.puts
      list.puts items.string

      list.string
    end
  end
end
