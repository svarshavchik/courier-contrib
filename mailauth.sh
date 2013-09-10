#!/bin/sh
# mailauth 20130907 (C) markc@renta.net (AGPLv3)
#
# A simple script to pull out the Message ID for any email address and
# then provide the actual initial login details for the Message ID. The
# use case is when the maillog script indicates a lot of outgoing messages
# that could be spam sent from a range of different From: addresses then
# this script will show the real login user. A simple change password for
# that real login user and a restart courier-mta (to drop the current
# connections) will stop the outgoing spam.
#
# cp mailauth.sh /usr/bin/mailauth
# chmod +x /usr/bin/mailauth

MAILLOG=/var/log/mail.info
HISTORY=/var/log/history.log

test -z $1 && echo "Usage: mailauth user@domain.com" && exit 1

TMP=$(grep 'from=<'$1 $MAILLOG | grep 'started,id=' | head -n 1)

if [ ! -z "$TMP" ]; then
    MID=$(echo "$TMP" | awk -F'started,id=' '{print $2}' | awk -F',from=' '{print $1}')
    grep $MID $MAILLOG | grep auth=
else
    echo "No outgoing email match for $1"
fi

echo "$(date +'%Y-%m-%d %X') $(whoami) $(basename $0) $*" >> $HISTORY

