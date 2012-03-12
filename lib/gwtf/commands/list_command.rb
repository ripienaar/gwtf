desc 'List active items'
command [:list, :ls, :l] do |c|
  c.desc 'Also show closed items'
  c.default_value false
  c.switch [:all, :a]

  c.desc 'Show a short summary for all projects'
  c.default_value false
  c.switch [:summary, :s]

  c.action do |global_options,options,args|
    if options[:summary]
      projects = Gwtf.projects(global_options[:data])
      longest_name = projects.map{|p| p.length}.max + 3

      projects.each_with_index do |project, idx|
        puts "Items in all projects:\n\n" if idx == 0

        items = Gwtf::Items.new(File.join(global_options[:data], project))

        open = 0
        closed = 0

        items.each_item do |item|
          item.open? ?  open += 1 : closed +=1
        end

        puts "%#{longest_name}s: open: %3d: closed %3d: total: %3d" % [ project, open, closed, open+closed ]

      end

      puts
    else
      count = {"open" => 0, "closed" => 0}

      @items.each_item do |item|
        count[ item[:status] ] += 1

        flags = []
        flags << "D" if item.has_description?
        flags << "C" if item.closed? && options[:all]

        puts "%5s %-4s%-12s%8s" % [ item.item_id, flags.join, Time.parse(item.created_at).strftime("%F"), item.subject ] if (options[:all] || item.open?)
      end

      puts
      puts "Project %s items: %d / %d" % [ global_options[:project], count["open"], count["open"] + count["closed"] ]
    end
  end
end


