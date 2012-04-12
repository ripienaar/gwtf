desc 'Tool to send various kinds of notification'

command [:notify] do |c|
  c.desc 'Email address to send to'
  c.default_value Etc.getlogin
  c.flag [:recipient, :r]

  c.desc 'Send a reminder about an item'
  c.default_value false
  c.flag [:remind]

  c.desc 'Send a overview list of all projects with items'
  c.default_value false
  c.switch [:overview]

  c.desc 'Send a list of any due or overdue items'
  c.default_value false
  c.switch [:due]

  c.desc 'When notifying about a specific item, close it after notify'
  c.default_value false
  c.switch [:done]

  c.desc 'Only notify about an open item'
  c.default_value false
  c.switch [:ifopen]

  c.action do |global_options,options,args|
    if options[:remind]
      raise "Need an item ID to remind" unless options[:remind] =~ /^(.+)$/

      item = @items.load_item(options[:remind])

      unless options[:ifopen] && item.closed?
        item.send_reminder(options[:recipient], options[:done])
      end

    elsif options[:overview]
      overview_text = Gwtf::Items.overview_text(global_options[:data])

      unless overview_text == ""
        options[:recipient].split(",").each do |r|
          next unless Gwtf.protocol_for_address(r) == "email"

          Gwtf::Notifier::Email.send_email(overview_text, "Summary of Tasks", r)
        end
      end

    elsif options[:due]
      Gwtf.color = false

      due_text = Gwtf::Items.due_text(global_options[:data])

      unless due_text == ""
        options[:recipient].split(",").each do |r|
          next unless Gwtf.protocol_for_address(r) == "email"

          Gwtf::Notifier::Email.send_email(due_text, "Due and Overdue Tasks", r)
        end
      end
    end
  end
end
