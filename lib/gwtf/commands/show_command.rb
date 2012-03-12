desc 'Show an item'
arg_name 'id'
command [:show, :s] do |c|
  c.action do |global_options,options,args|
    raise "Please supply an item ID to show" if args.empty?

    item = @items.load_item(args.first)

    puts item.summary
  end
end
