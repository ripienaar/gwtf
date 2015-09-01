module Gwtf
  module Notifier
    class Pushover<Base
      def notify
        config_file = File.join(Etc.getpwuid.dir, ".pushover")

        raise "Please configure pushover in ~/.pushover" unless File.exist?(config_file)

        config = YAML.load_file(config_file)

        raise "Config needs to be a hash" unless config.is_a?(Hash)
        raise "Config must include :app_token" unless config[:app_token]

        uri = URI.parse(recipient)

        raise "Recipient must have a host portion" unless uri.host

        ::Pushover.token = config[:app_token]
        ::Pushover.user = uri.host

        if item.project == "default"
          msg = "%s: %s" % [ item.item_id, item.subject ]
        else
          msg = "%s:%s: %s" % [ item.project, item.item_id, item.subject ]
        end

        result = ::Pushover.notification(
          :title => config.fetch(:title, "gwtf"),
          :sound => config.fetch(:sound, "pushover"),
          :message => msg
        )

        unless result.code == 200
          raise("Failed to notify via pushover: %s" % responce.inspect)
        end
      end
    end
  end
end

