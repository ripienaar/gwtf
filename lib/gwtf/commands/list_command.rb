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

  c.action do |global_options,options,args|
    if options[:summary]
      projects = Gwtf.projects(global_options[:data])
      longest_name = projects.map{|p| p.length}.max

      projects.each_with_index do |project, idx|
        puts "Items in all projects:\n\n" if idx == 0

        items = Gwtf::Items.new(File.join(global_options[:data], project), project)
        stats = items.stats

        puts "%#{longest_name + 3}s: open: %3d: closed %3d: total: %3d" % [ project, stats["open"], stats["closed"], stats["total"] ] unless stats["total"] == 0

      end

      puts
    elsif options[:overview]
      Gwtf.projects(global_options[:data]).each do |project|
        items = Gwtf::Items.new(File.join(global_options[:data], project), project)

        puts items.list_text(options[:all]) if items.item_ids.size > 0
        puts
      end
    else
      puts
      puts @items.list_text(options[:all])
      puts
    end
  end
end


