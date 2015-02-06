#!/bin/bash
#
# Cancel all messages in the queue.
#
# Viktor Szépe <viktor@szepe.net>
# /usr/local/sbin/cancelallmsgs.sh

MAIL_GROUP="daemon"

mailq -sort -batch | head -n -1 | cut -d';' -f 2,4 \
    | while read ID_USER; do
        # message cancellation needs privileges
        sudo -u ${ID_USER#*;} -g "$MAIL_GROUP" -- cancelmsg ${ID_USER%;*}
    done
