#!/usr/bin/env bash
#
# Runner process to call the rake task that controls the export to SIS
#

# source the helper...
DIR=$(dirname $0)
. $DIR/common.sh

# set the appropriate logger
export NAME=$(basename $0 .sh)
export LOGGER=$(logger_name "$NAME.log")

# the time we want the action to occur
# this is the time in EST
export ACTION_TIME="21:45"
export ACTION_TIMEZONE="EST"

# we are running in UTC
#export ACTION_TIME="01:45"
#export ACTION_TIMEZONE="UTC"

# helpful message...
logit "Starting up..."

# forever...
while true; do

   # sleeping message...
   logit "Sleeping until $ACTION_TIME $ACTION_TIMEZONE..."
   sleep_until $ACTION_TIME $ACTION_TIMEZONE

   # determine if we are the active host... only run on one host even though we may be deployed on many
   if is_active_host; then

      # starting message
      logit "Beginning SIS export sequence"

      # do the optional import
      rake libraetd:sis:export >> $LOGGER 2>&1
      res=$?

      # ending message
      logit "SIS export sequence completes with status: $res"

   else
      logit "Not the active host; doing nothing"
   fi

   # sleep for another minute
   sleep 60

done

# never get here...
exit 0

#
# end of file
#
