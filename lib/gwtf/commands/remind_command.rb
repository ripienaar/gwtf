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

  c.action do |global_options,options,args|
    raise "Please supply an item ID to remind about" if args.empty?

    unless options[:send]
      raise "Please specify a valid at() time specification" unless args.size > 2

      at = args[1..-1].join(" ")

      STDOUT.sync

      print "Creating reminder at job for item #{args.first}: "
      system "echo gwtf --project='%s' remind --recipient='%s' --send %s|at %s" % [ global_options[:project], options[:recipient], args.first, at]
    else
      item = @items.load_item(args.first)

      begin
        tmp = Tempfile.new("gwtf")
        tmp.write(item.summary)
        tmp.rewind

        if global_options[:project] == "default"
          subject = "Reminder for item %s" % [ args.first ]
        else
          subject = "Reminder for item %s in %s project" % [ args.first, global_options[:project] ]
        end

        system("cat #{tmp.path}|mail -s '#{subject}' '#{options[:recipient]}'")
      ensure
        tmp.close
        tmp.unlink
      end
    end
  end
end


