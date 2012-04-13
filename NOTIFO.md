Notifo Notifications
====================

You can use notifo to send notifications to your iPhone or Android
phone.

To configure it you need to go signup at http://notifo.com

Install the notifo gem:

    gem install notifo

Once you've done that you can configure gwtf with your
API access details in _~/.notifo_ a sample file is:

    ---
    :apiuser: cornet
    :apisecret: abcdef1234567890abcdef123456789abcdef1234
    :sender: gwtf

Supply your own apikey and apiuser. Send alerts by using the
--recipient argument:

    t remind 31 "now + 1 week" --recipient=notifo://you@notifo.com

This will schedule a alert to be sent to your notifo instead
of the default email.
