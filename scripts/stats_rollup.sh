#!/usr/bin/env bash
#
# Runner process to call the rake task that rolls up the daily download and view statistics
#

# source the helper...
DIR=$(dirname $0)
. $DIR/common.sh

# set the appropriate logger
export NAME=$(basename $0 .sh)
export LOGGER=$(logger_name "$NAME.log")

# the time we want the action to occur
# this is specified in localtime
export ACTION_TIME="00:15"
export ACTION_TIMEZONE="America/New_York"

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
      logit "Beginning statistics rollup sequence"

      # do the optional import
      rake libraetd:statistics:create_yesterdays_aggregate >> $LOGGER 2>&1
      res=$?

      # ending message
      logit "Statistics rollup sequence completes with status: $res"

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
