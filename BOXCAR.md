Boxcar Notifications
====================

You can use boxcar to send notifications to your iPhone
or Mac Desktop - Android and Windows supported soon.

To configure it you need to go signup at http://boxcar.io
and create a provider - review their docs at http://boxcar.io/help/api/providers

Once you've done that you can configure gwtf with your
API access details in _~/.boxcar_ a sample file is:

    ---
    :apikey: 123456
    :apisecret: 0987654321
    :serviceid: 12345
    :sender: gwtf

Supply your own apikey, secret and service id you can then
subscribe to that service o your iphone and start sending
alerts by using the --recipient argument:

    t remind 31 "now + 1 week" --recipient=boxcar://you@your.com

This will schedule a alert to be sent to your boxcar instead
of the default email.
