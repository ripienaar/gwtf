desc 'Mark an item as done'
arg_name 'Item id'
command [:done, :close, :d, :c] do |c|
  c.action do |global_options,options,args|
    raise "Please specify an item ID to mark as done" if args.empty?

    item = @items.load_item(args.first)
    item.close
    item.save

    puts "Marked item #{args.first} as done"
  end
end


