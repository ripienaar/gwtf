Boxcar Notifications
====================

You can use boxcar to send notifications to your phone

Signup to boxcar.io from your phone and get the Access
Token from your device, configure ```~/.boxcar```:

    ---
    :icon_url: http://www.devco.net/images/gwtf.jpg
    :source_name: gwtf
    :sound: notifier-1

Supply your own apikey, secret and service id you can then
subscribe to that service o your iphone and start sending
alerts by using the --recipient argument:

    t remind 31 "now + 1 week" --recipient=boxcar://ACCESS_TOKEN

This will schedule a alert to be sent to your boxcar instead
of the default email.  You can use the same format in the
config file recipients
