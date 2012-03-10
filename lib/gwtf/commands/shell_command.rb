desc 'Start work on an item in a subshell'
arg_name 'Item id'
command :shell do |c|
  c.action do |global_options,options,args|
    raise "Please specify an item ID to work on" if args.empty?
    raise "SHELL is not set, cannot create sub shell" unless ENV.include?("SHELL")

    start_time = Time.now
    item = @items.load_item(args.first)

    puts "Starting work on item #{item.item_id}, exit to record the action and time"

    ENV["GWTF_ITEM"] = item.item_id.to_s
    ENV["GWTF_PROJECT"] = global_options[:project]

    system(ENV["SHELL"])

    elapsed_time = Time.now - start_time

    STDOUT.sync = true

    print "Optional description for work log: "

    begin
      description = STDIN.gets.chomp
    rescue Exception
      puts
      description = ""
    end

    description = "Worked in a subshell" if description == ""
    description = description + " (#{Gwtf.seconds_to_human(elapsed_time.round)})"

    item.record_work(description, elapsed_time.round)

    item.save

    puts "Recorded #{elapsed_time} seconds of work against item #{item.item_id}"
  end
end


