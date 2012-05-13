## cancelmailq

_20120513 (C) markc@renta.net (AGPLv3)_

This script provides a way to cancel messages from the mail queue
for a particular user rather than just per message-id with cancelmsg.
It comes in handy if there is spam going out from a user and you need
to cancel unsent messages as quickly as possible. Cancelling messages
for the "daemon" user will cancel pending bounces. Uncomment the history
line if not needed.

## maillog

_20120513 (C) markc@renta.net (AGPLv3)_

An awk script to provide a simple uncluttered view of in and out going
mail deliveries with the size of the message as a bonus in the first
field. Set the MAILLOG variable to where your Courier mail logfile is
kept and comment out the usage history line if not needed.
