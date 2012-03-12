desc 'List active items'
command [:list, :ls, :l] do |c|
  c.desc 'Also show closed items'
  c.default_value false
  c.switch [:all, :a]

  c.action do |global_options,options,args|
    count = {"open" => 0, "closed" => 0}

    @items.each_item do |item|
      count[ item[:status] ] += 1

      flags = []
      flags << "D" if item.has_description?
      flags << "C" if item.closed? && options[:all]

      puts "%5s %-4s%-10s%8s" % [ item.item_id, flags.join, Time.parse(item.created_at).strftime("%D"), item.subject ] if (options[:all] || item.open?)
    end

    puts
    puts "Items: %d / %d" % [ count["open"], count["open"] + count["closed"] ]
  end
end


