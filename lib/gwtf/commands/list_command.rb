desc 'List active items'
command [:list, :ls, :l] do |c|
  c.desc 'Also show closed items'
  c.default_value false
  c.switch [:all, :a]

  c.action do |global_options,options,args|
    count = {"open" => 0, "closed" => 0}

    @items.each_item do |item|
      count[ item[:status] ] += 1

      item.has_description ? id = "*#{item.item_id.to_s}" : id = item.item_id.to_s

      puts "%5s %-3s%8s" % [ id, "", item.subject] if item.open?
      puts "%5s %-3s%8s" % [ id, "C", item.subject] if (item.closed? && options[:all])
    end

    puts
    puts "Items: %d / %d" % [count["open"], count["open"] + count["closed"]]
  end
end


