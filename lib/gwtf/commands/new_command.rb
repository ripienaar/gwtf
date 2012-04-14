desc 'Create an item'
arg_name 'Short item description'
command [:new, :add, :n, :a, :c] do |c|
  c.desc 'Due date for the item (yyyy/mm/dd)'
  c.default_value false
  c.flag [:due]

  c.desc 'Invoke EDITOR to provide a long form description'
  c.default_value false
  c.switch [:edit, :e]

  c.desc 'Schedule a reminder about this task'
  c.default_value false
  c.flag [:remind]

  c.desc 'Mark item done after sending reminder'
  c.default_value false
  c.switch [:done]

  c.desc 'Only alert if the item is still marked open'
  c.default_value false
  c.switch [:ifopen]

  c.desc 'Email address to send to'
  c.default_value Etc.getlogin
  c.flag [:recipient, :r]

  c.action do |global_options,options,args|
    subject = args.join(" ")
    raise "Please supply a short desciption for the item on the command line" if subject == ""

    if options[:edit]
      raise "EDITOR is not set" unless ENV.include?("EDITOR")

      begin
        tmp = Tempfile.new("gwtf")
        system("%s %s" % [ENV["EDITOR"], tmp.path])
        description = tmp.read.chomp
      ensure
        tmp.close
        tmp.unlink
      end
    else
      description = nil
    end

    item = @items.new_item
    item.subject = subject
    item.description = description if description
    item.due_date = item.date_to_due_date(options[:due]) if options[:due]

    if options[:remind]
      STDOUT.sync

      print "Creating reminder at job for item #{item.item_id}: "

      item.schedule_reminer(options[:remind], options[:recipient], options[:done], options[:ifopen])
    end

    item.save

    puts item.to_s
  end
end
