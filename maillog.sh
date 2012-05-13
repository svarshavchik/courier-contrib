#!/bin/sh
# maillog 20120513 (C) markc@renta.net (AGPLv3)
#
# An awk script to provide a simple uncluttered view of in and out going
# mail deliveries with the size of the message as a bonus in the first
# field. Set the MAILLOG variable to where your Courier mail logfile is
# kept and comment out the usage history line if not needed.
#
# cp maillog.sh /usr/bin/maillog
# chmod +x /usr/bin/maillog

MAILLOG=/var/log/mail.info
HISTORY=/var/log/history.log

tail -f $MAILLOG | \
  awk -F, ' \
    /Message delivered./ { \
    print \
    substr($4,6)"\t" \
    substr($3,7,length($3)-7)" \033[1;32m<-\033[0m " \
    substr($2,7,length($2)-7) \
  } \
    /status: success/ { \
    print \
    substr($4,6)"\t" \
    substr($2,7,length($2)-7)" \033[1;31m->\033[0m " \
    substr($3,7,length($3)-7) \
  }'

echo "$(date +'%Y-%m-%d %X') $(whoami) $(basename $0) $*" >> $HISTORY
