module Gwtf
  module Notifier
    class Boxcar<Base
      def notify
        config_file = File.join(Etc.getpwuid.dir, ".boxcar")

        raise "Please configure boxcar in ~/.boxcar" unless File.exist?(config_file)

        config = YAML.load_file(config_file)

        raise "Config needs to be a hash" unless config.is_a?(Hash)
        raise "Config must include :apikey" unless config[:apikey]
        raise "Config must include :apisecret" unless config[:apisecret]
        raise "Config must include :serviceid" unless config[:serviceid]
        raise "Config must include :sender" unless config[:sender]

        uri = URI.parse(recipient)

        raise "Recipient must have a user portion" unless uri.user
        raise "Recipient must have a host portion" unless uri.host

        email_address = "%s@%s" % [uri.user, uri.host]

        bp = BoxcarAPI::Provider.new(config[:apikey], config[:apisecret], config[:sender])

        if item.project == "default"
          msg = "%s: %s" % [ item.item_id, item.subject ]
        else
          msg = "%s:%s: %s" % [ item.project, item.item_id, item.subject ]
        end

        res = bp.notify(email_address, msg, {:from_screen_name => config[:sender], :icon_url => "http://www.devco.net/images/gwtf.jpg"})

        raise "Failed to send message to Boxcar, got code #{res.code}" unless res.code == 200
      end
    end
  end
end
