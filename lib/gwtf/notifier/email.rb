module Gwtf
  module Notifier
    class Email<Base
      def notify
        begin
          tmp = Tempfile.new("gwtf")
          tmp.write(item.summary)
          tmp.rewind

          if item.project == "default"
            subject = "Reminder for item %s" % [ item.item_id ]
          else
            subject = "Reminder for item %s in %s project" % [ item.item_id, item.project ]
          end

          system("cat #{tmp.path} | mail -s '#{subject}' '#{recipient}'")
        ensure
          tmp.close
          tmp.unlink
        end
      end
    end
  end
end
