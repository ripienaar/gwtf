desc 'Start work on an item in a subshell'
arg_name 'Item id'
command :shell do |c|
  c.desc 'Runs a script before starting the sub-shell'
  c.default_value nil
  c.flag [:pre]

  c.desc 'Runs a script after the sub-shell'
  c.default_value nil
  c.flag [:post]

  c.action do |global_options,options,args|
    raise "Please specify an item ID to work on" if args.empty?
    raise "SHELL is not set, cannot create sub shell" unless ENV.include?("SHELL")

    start_time = Time.now
    item = @items.load_item(args.first)

    puts "Starting work on item #{item.item_id}, exit to record the action and time"

    ENV["GWTF_ITEM"] = item.item_id.to_s
    ENV["GWTF_PROJECT"] = global_options[:project]
    ENV["GWTF_SUBJECT"] = item.subject

    if options[:pre]
      system(options[:pre])
    end

    system(ENV["SHELL"])

    if options[:post]
      system(options[:post])
    end

    elapsed_time = Time.now - start_time

    STDOUT.sync = true

    begin
      description = Gwtf.ask "Optional description for work log (start with done! to close): "

      if description =~ /^(done|close)!\s*(.+)/
        description = $2
        item.close
      end
    rescue Exception
      puts
      description = ""
    end

    description = "Worked in a subshell" if description == ""

    item.record_work(description, elapsed_time.round)

    item.save

    puts "Recorded #{Gwtf.seconds_to_human(elapsed_time.round)} of work against item: #{item}"
  end
end


