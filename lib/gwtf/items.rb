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

    def initialize(data_dir)
      raise "Data directory #{data_dir} does not exist" unless File.directory?(data_dir)

      @data_dir = data_dir
      @config = read_config
    end

    def new_item
      item = Item.new
      item.item_id = @config["next_item"]
      item.file = File.join(@data_dir, "#{item.item_id}.gwtf")

      @config["next_item"] += 1
      save_config

      item
    end

    def load_item(item)
      raise "Item #{item} does not exist" unless File.exist?(file_for_item(item))

      Item.new(file_for_item(item))
    end

    def read_config
      JSON.parse(File.read(Items.config_file(@data_dir)))
    end

    def save_config
      raise "Config has not been loaded" unless @config

      File.open(Items.config_file(@data_dir), "w") do |f|
        f.print(@config.to_json)
      end
    end

    def item_ids
      Dir.entries(@data_dir).grep(/\.gwtf$/).map{|i| File.basename(i, ".gwtf")}.map{|i| Integer(i)}.sort
    end

    def file_for_item(item)
      File.join(@data_dir, "#{item}.gwtf")
    end

    def each_item
      item_ids.each {|item| yield load_item(item) }
    end
  end
end
