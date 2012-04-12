module Gwtf
  module Notifier
    class Notifo<Base
      def notify
        config_file = File.join(Etc.getpwuid.dir, ".notifo")

        raise "Please configure notifo in ~/.notifo" unless File.exist?(config_file)

        config = YAML.load_file(config_file)

        p config

        raise "Config needs to be a hash" unless config.is_a?(Hash)
        raise "Config must include :apiuser" unless config[:apiuser]
        raise "Config must include :apisecret" unless config[:apisecret]

        uri = URI.parse(recipient)

        raise "Recipient must have a user portion" unless uri.user
        raise "Recipient must have a host portion" unless uri.host

        notifo = ::Notifo.new(:username => config[:apiuser], :secret => config[:apisecret])

        if item.project == "default"
          msg = "%s: %s" % [ item.item_id, item.subject ]
        else
          msg = "%s:%s: %s" % [ item.project, item.item_id, item.subject ]
        end

        notifo.send_notification(:to => uri.user, :msg =>  msg)

      end
    end
  end
end
