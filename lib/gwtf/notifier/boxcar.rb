module Gwtf
  module Notifier
    class Boxcar<Base
      def notify
        config_file = File.join(Etc.getpwuid.dir, ".boxcar")

        raise "Please configure boxcar in ~/.boxcar" unless File.exist?(config_file)

        config = YAML.load_file(config_file)

        raise "Config needs to be a hash" unless config.is_a?(Hash)
        raise "Config must include :icon_url" unless config[:icon_url]
        raise "Config must include :source_name" unless config[:source_name]
        raise "Config must include :sound" unless config[:sound]

        uri = URI.parse(recipient)

        raise "Recipient must have a host portion" unless uri.host

        if item.project == "default"
          msg = "%s: %s" % [ item.item_id, item.subject ]
        else
          msg = "%s:%s: %s" % [ item.project, item.item_id, item.subject ]
        end

        api_uri = URI.parse("https://new.boxcar.io/api/notifications")
        http = Net::HTTP.new(api_uri.host, api_uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Post.new(api_uri.path)

        request.set_form_data("user_credentials" => uri.host,
                              "notification[title]" => item.subject,
                              "notification[long_message]" => msg,
                              "notification[sound]" => config[:sound],
                              "notification[source_name]" => config[:source_name],
                              "notification[icon_url]" => config[:icon_url])

        res = http.request(request)

        raise "Failed to send message to Boxcar, got code #{res.code}" unless res.code == "201"
      end
    end
  end
end
