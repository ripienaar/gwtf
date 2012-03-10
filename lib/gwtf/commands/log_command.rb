desc 'Log work performed against an item'
arg_name 'id log text'
command :log do |c|
  c.desc 'Days spent'
  c.default_value 0
  c.flag [:days, :d]

  c.desc 'Hours spent'
  c.default_value 0
  c.flag [:hour, :h]

  c.desc 'Minutes spent'
  c.default_value 0
  c.flag [:min, :m]

  c.action do |global_options,options,args|
    raise "Please specify an item ID to work on" if args.empty?
    raise "Please supply log text" if args.size == 1

    elapsed_time = Float(options[:days]) * 60 * 60 * 24
    elapsed_time += Float(options[:hour]) * 60 * 60
    elapsed_time += Float(options[:min]) * 60

    item = @items.load_item(args.first)

    description = args[1..-1].join(" ")

    item.record_work(description, elapsed_time)

    item.save

    puts "Logged '#{description}' against item #{item.item_id} for #{Gwtf.seconds_to_human(elapsed_time)}"
  end
end


