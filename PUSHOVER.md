Pushover Notifications
======================

You can use Pushover to send notifications to your phones or
desktop

To configure it you need to go signup at https://pushover.net/

Install the pushover gem:

    gem install pushover

You should set up a application under your own account, it would
get API Token unique to your application, configure this in
_~/.pushover_:

    ---
    :app_token: XXXXXXXXXXXXXXXXXXXX
    :title: gwtf
    :sound: spacealarm

The title is optional, _gwtf_ will be used by default.
The sound is optional and should be one from the list here: https://pushover.net/api#sounds

Each user have a unique User key you find on their website, this is
the recipient part to use when notifying :

    pushover://uXXXXXXXXXX

This way you can notify multiple people from the same app etc
