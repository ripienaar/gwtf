desc 'Show an item'
arg_name 'Item ID'
command [:show, :s] do |c|
  c.action do |global_options,options,args|
    raise "Please supply an item ID to show" if args.empty?

    item = @items.load_item(args.first)

    time_worked = item.work_log.inject(0) do |result, log|
      begin
        result + log["elapsed"]
      rescue
        result
      end
    end

    puts "         ID: %s" % [ item.item_id ]
    puts "    Subject: %s" % [ item.subject ]
    puts "     Status: %s" % [ item.status ]
    puts "Time Worked: %s" % [ Gwtf.seconds_to_human(time_worked) ]
    puts "    Created: %s" % [ Time.parse(item.created_at).strftime("%D %R") ]
    puts "     Closed: %s" % [ Time.parse(item.closed_at).strftime("%D %R") ] if item.closed?

    if item.has_description?
      puts
      puts "Description:"

      item.description.split("\n").each do |line|
        puts "%13s%s" % [ "", line]
      end

      puts
    end

    time_spent = 0

    item.work_log.each_with_index do |log, idx|
      puts "Work Log: " if idx == 0

      puts "%27s %s" % [Time.parse(log["time"]).strftime("%D %R"), log["text"]]
    end
  end
end
