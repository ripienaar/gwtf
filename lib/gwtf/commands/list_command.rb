desc 'List active items'
command [:list, :ls, :l] do |c|
  c.desc 'Also show closed items'
  c.default_value false
  c.switch [:all, :a]

  c.desc 'Show a short summary for all projects'
  c.default_value false
  c.switch [:summary, :s]

  c.desc 'Show a overview for all projects'
  c.default_value false
  c.switch [:overview, :o]

  c.desc 'Show due and overdue items for all projects'
  c.default_value false
  c.switch [:due]

  c.action do |global_options,options,args|
    if options[:summary]
      projects = Gwtf.projects(global_options[:data])
      longest_name = projects.map{|p| p.length}.max

      projects.each_with_index do |project, idx|
        next if project == "reminders"

        puts "Items in all projects:\n\n" if idx == 0

        items = Gwtf::Items.new(File.join(global_options[:data], project), project)
        stats = items.stats

        unless stats["open"] == 0
          msg = "%#{longest_name + 3}s: open: %-3d closed %-3d overdue: %-3d total: %-3d" % [ project, stats["open"], stats["closed"], stats["overdue"], stats["total"] ]

          if stats["overdue"] > 0
            puts Gwtf.red(msg)
          elsif stats["due_soon"] > 0
            puts Gwtf.yellow(msg)
          else
            puts Gwtf.green(msg)
          end
        end
      end
      puts

    elsif options[:due]
      Gwtf.projects(global_options[:data]).each do |project|
        next if project == "reminders"

        items = Gwtf::Items.new(File.join(global_options[:data], project), project)

        items.each_item do |item|
          puts "%s: %s" % [ project, item.to_s ] if item.due?
        end
      end

    elsif options[:overview]
      puts Gwtf::Items.overview_text(global_options[:data], options[:all])

    else
      puts
      puts @items.list_text(options[:all])
      puts
    end
  end
end


