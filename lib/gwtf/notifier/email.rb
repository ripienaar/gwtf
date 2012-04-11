module Gwtf
  module Notifier
    class Email<Base
      def self.send_email(body, subject, recipient)
        tmp = Tempfile.new("gwtf")
        tmp.write(body)
        tmp.rewind

        subject.gsub!("'", "\'")
        recipient.gsub!("'", "\'")

        system("cat #{tmp.path} | mail -s '#{subject}' '#{recipient}'")
      ensure
        tmp.close!
      end

      def notify
        if item.project == "default"
          subject = "Reminder for item %s" % [ item.item_id ]
        else
          subject = "Reminder for item %s in %s project" % [ item.item_id, item.project ]
        end

        Email.send_email(item.summary, subject, recipient)
      end
    end
  end
end
