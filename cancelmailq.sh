#!/bin/sh
# cancelmailq 20120513 (C) markc@renta.net (AGPLv3)
#
# This script provides a way to cancel messages from the mail queue
# for a particular user rather than just per message-id with cancelmsg.
# It comes in handy if there is spam going out from a user and you need
# to cancel unsent messages as quickly as possible. Cancelling messages
# for the "daemon" user will cancel pending bounces. Uncomment the history
# line if not needed.
#
# cp cancelmailq.sh /usr/bin/cancelmailq
# chmod +x /usr/bin/cancelmailq

test -z $1 && echo "Usage: cancelmailq user@domain|daemon" && exit 1

HISTORY=/var/log/history.log

if [ "$1" = "daemon" ]; then
  mailq | grep -B1 'daemon           $' | sed -n 's/.*\(................\.................\.........\).*/cancelmsg \1/p' | sh
else
  mailq | grep -B1 $1 | sed -n 's/.*\(................\.................\.........\).*/cancelmsg \1/p' | sh
fi
courier flush

echo "$(date +'%Y-%m-%d %X') $(whoami) $(basename $0) $*" >> $HISTORY
