desc 'Manage or send reminders about an item'
long_desc <<EOF
Schedule a reminder for an existing task: gwtf remind 10 now +5 minutes

Send a reminder for an existing task immediately: gwtf remind 10 --send

Add a new item to the reminders project and schedule a reminder: gwtf remind --at="noon tomorrow" have lunch

Time specifications are in at(1) format.
EOF

command [:remind, :rem] do |c|
  c.desc 'Email address to send to'
  c.default_value Etc.getlogin
  c.flag [:recipient, :r]

  c.desc 'Send email immediately'
  c.default_value false
  c.switch [:send]

  c.desc 'Mark item done after sending reminder'
  c.default_value false
  c.switch [:done]

  c.desc 'Only alert if the item is still marked open'
  c.default_value false
  c.switch [:ifopen]

  c.desc "at(1) time specification for the reminder to be sent"
  c.default_value nil
  c.flag [:at]

  c.action do |global_options,options,args|
    raise "Please supply an item ID to remind about" if args.empty?

    STDOUT.sync

    unless options[:send]
      if args.first =~ /^\d+$/ # got an item id, schedule a reminder
        unless options[:at]
          raise "Please specify a valid at(1) time specification with --at after the item id" unless args.size > 2
          options[:at] = args[1..-1].join(" ")
        end

        print "Creating reminder at job for item #{args.first}: "

        @items.load_item(args.first).schedule_reminer(options[:at], options[:recipient], options[:done], options[:ifopen])

      else # new reminder in the 'reminders' project
        raise "Please specify an at(1) time specification" unless options[:at]
        raise "Please specify a subject for the reminder item" if args.empty?

        project_dir = File.join(global_options[:data], "reminders")
        Gwtf::Items.setup(project_dir) unless File.directory?(project_dir)

        items = Gwtf::Items.new(project_dir, "reminders")
        reminder = items.new_item
        reminder.subject = args.join(" ")

        print "Creating reminder at job for item #{reminder.item_id}: "
        out = reminder.schedule_reminer(options[:at], options[:recipient], true, true)

        reminder.record_work "Scheduled reminder for %s: %s" % [ options[:at], out.chomp ]

        reminder.save

        puts reminder.to_s
      end
    else
      item = @items.load_item(args.first)

      unless options[:ifopen] && item.closed?
        options[:recipient].split(",").each do |recipient|
          item.send_reminder(recipient.strip, options[:done], Gwtf.notifier_for_address(recipient.strip))
        end
      end
    end
  end
end
