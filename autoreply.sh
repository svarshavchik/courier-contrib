#!/bin/bash -e
# autoreply 20150130 (C) Mark Constable <markc@renta.net> (AGPL-3.0)
#
# A simple vacation autoreply script for courier-mta based mailservers.
#
# Depends on these conditions:
#
# - courier-imap/mta with courier-authdaemon and maildrop installed
# - nano is installed (and "stat", part of the coreutils package)
# - the MAILDIR variable below is set to the root of your maildir folders
# - the users .mailfilter is not used for anything else
#
# Usage:
#
# autoreply                   - show simple usage text and exit
# autoreply fi                - find all occurences of autoreply.txt, and status
# autoreply sh email@address  - show the current autoreply.txt
# autoreply ed email@address  - edit/create an autoreply for email@address
# autoreply en email@address  - enable autoreply for user
# autoreply di email@address  - disable autoreply for user
# autoreply rm email@address  - completely remove users autoreply
#
# Thanks to Bowie Bailey for the spam/mailing-list test.
#
#set -x

# This is only needed for the find all autoreplies option
MAILDIRS=/home/m

test -z "$1" && echo "Usage: autoreply sh(ow)|ed(it)|en(able)|di(sable)|rm(remove) email@address|fi(indall)" && exit 1

if [ "$1" = "fi" -a -z "$2" ]; then
  echo "Please be patient while all users are checked..."
  echo
  while read -r AUTOREPLY
  do
    HDIR=$(dirname $AUTOREPLY)
    if [ -f $HDIR/.mailfilter ]; then
      ACTIVE="enabled"
    elif [ -f $HDIR/mailfilter ]; then
      ACTIVE="disabled"
    else
      ACTIVE="ERROR: mailfilter does not exist"
    fi
    echo $HDIR $ACTIVE
  done < <(find $MAILDIRS -type f -name autoreply.txt)
  exit 2
elif [ "$1" != "fi" -a -z "$2" ]; then
  echo "Please provide an email address"
  exit 2
fi

HOMEDIR=$(authtest $2 2>/dev/null | awk '/Home Directory:/ {print $3}')

if [ -z "$HOMEDIR" ]; then
  echo "ERROR: No homedir for $2"
  exit 2
fi

EMAIL=$2

show()
{
  if [ -f $HOMEDIR/autoreply.txt ]; then
    if [ -f $HOMEDIR/.mailfilter ]; then
      echo "Autoreply currently: Enabled"
      echo
      grep ^SUBJECT $HOMEDIR/.mailfilter
    elif [ -f $HOMEDIR/mailfilter ]; then
      echo "Autoreply currently: Disabled"
      echo
      grep ^SUBJECT $HOMEDIR/mailfilter
    else
      echo "Error: missing mailfilter, remove and re-setup"
    fi
    echo
    cat $HOMEDIR/autoreply.txt
  else
    echo "There is no autoreply for $EMAIL"
  fi
}

edit()
{
  if [ ! -f $HOMEDIR/autoreply.txt ]; then
    cat << EOS > $HOMEDIR/mailfilter
MAILTO=escape(\$RECIPIENT)
MAILFROM=escape(\$SENDER)
SUBJECT="Auto responder for $EMAIL"
if (! (/^X-Spam-Flag: YES/ || /^List-id:/ || /^Precedence: bulk/ || /^Precedence: junk/) )
{
\`mailbot -t "./autoreply.txt" -d "./autoreply" -A "To: \$MAILFROM" -A "From: \$MAILTO" -s "\$SUBJECT" -T forwardatt \$SENDMAIL -f "\$MAILTO"\`
}
EOS
    echo "Type or paste the vacation autoreply text, ctrl-x to save and quit, and then ENABLE the autoreply when ready"
    echo
    sleep 2
  fi
  nano -t -x -c $HOMEDIR/autoreply.txt

  # This is redundant after the first time they are created
  if [ -f $HOMEDIR/mailfilter ]; then
    MUID=$(stat -c %u $HOMEDIR)
    MGID=$(stat -c %g $HOMEDIR)
    chown $MUID:$MGID $HOMEDIR/{autoreply.txt,mailfilter}
    chmod 600 $HOMEDIR/{autoreply.txt,mailfilter}
  fi
}

enable()
{
  if [ -f $HOMEDIR/.mailfilter ]; then
    echo "Autoreply already enabled"
  elif [ -f $HOMEDIR/mailfilter ]; then
    mv $HOMEDIR/mailfilter $HOMEDIR/.mailfilter
    echo "Autoreply now enabled"
  else
    echo "ERROR: mailfilter to activate autoreply does not exist, use EDIT to create one"
  fi
}

disable()
{
  if [ -f $HOMEDIR/.mailfilter ]; then
    mv $HOMEDIR/.mailfilter $HOMEDIR/mailfilter
    echo "Autoreply now disabled"
  elif [ -f $HOMEDIR/mailfilter ]; then
    echo "Autoreply already disabled"
  else
    echo "ERROR: mailfilter to activate autoreply does not exist, use EDIT to create one"
  fi
}

remove()
{
  if [ -f $HOMEDIR/.mailfilter ]; then
    echo "Autoreply enabled, please disable first"
  else
    if [ -f $HOMEDIR/mailfilter ]; then
      rm $HOMEDIR/mailfilter
      echo "Removed $HOMEDIR/mailfilter (autoreply activation script)"
    else
      echo "Problem: no $HOMEDIR/mailfilter"
    fi
    if [ -f $HOMEDIR/autoreply.txt ]; then
      rm $HOMEDIR/autoreply.*
      echo "Removed $HOMEDIR/autoreply.txt (autoreply autoreply content)"
    else
      echo "Problem: no $HOMEDIR/autoreply.txt"
    fi
  fi
}

case $1 in
  sh) show ;;
  ed) edit ;;
  en) enable ;;
  di) disable ;;
  rm) remove ;;
  *) echo "Please provide one of sh, ed, en, di, rm, fi"
esac

echo "$(date +'%Y-%m-%d %X') $(whoami) $(basename $0) $*" >> /var/log/history.log
