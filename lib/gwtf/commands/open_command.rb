desc 'Re-open a previously closed item'
arg_name 'Item id'
command [:open, :o] do |c|
  c.action do |global_options,options,args|
    raise "Please specify an item ID to mark re-open" if args.empty?

    item = @items.load_item(args.first)

    raise "Item #{args.first} was already open" if item.open?

    item.open
    item.save

    puts item.to_s
  end
end
