desc 'Send a reminder about an item via email'
arg_name 'id [at time specification]'
long_desc <<EOF
When run without the --send option this comand will
add an at() job using the supplied at time specification.

The at job will call the same command again this time
with the --send option that will send an email to you
or the address specified in --recipient using your system
mail command
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

  c.action do |global_options,options,args|
    raise "Please supply an item ID to remind about" if args.empty?

    unless options[:send]
      raise "Please specify a valid at() time specification" unless args.size > 2

      STDOUT.sync

      print "Creating reminder at job for item #{args.first}: "

      @items.load_item(args.first).schedule_reminer(args[1..-1].join(" "), options[:recipient], options[:done], options[:ifopen])
    else
      item = @items.load_item(args.first)

      unless options[:ifopen] && item.closed?
        item.send_reminder(options[:recipient], options[:done], Gwtf::Notifier::Email)
      end
    end
  end
end
