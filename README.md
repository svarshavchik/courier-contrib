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

## mailauth

_20130907 (C) markc@renta.net (AGPLv3)_

A simple script to pull out the Message ID for any email address and
then provide the actual initial login details for the Message ID. The
use case is when the maillog script indicates a lot of outgoing messages
that could be spam sent from a range of different From: addresses then
this script will show the real login user. A simple change password for
that real login user and a restart courier-mta (to drop the current
connections) will stop the outgoing spam.
