#!/usr/bin/env bash
#
# Runner process to call the rake tasks that control deposit importing from optional registration
#

# source the helper...
DIR=$(dirname $0)
. $DIR/common.sh

# set the appropriate logger
export NAME=$(basename $0 .sh)
export LOGGER=$(logger_name "$NAME.log")

# our sleep time, currently 2 minutes
export SLEEPTIME=120

# helpful message...
logit "Starting up..."

# forever...
while true; do

   # sleeping message...
   logit "Sleeping for $SLEEPTIME seconds..."
   sleep $SLEEPTIME

   # determine if we are the active host... only run on one host even though we may be deployed on many
   if is_active_host; then

      # starting message
      logit "Beginning optional deposit import sequence"

      # do the optional import
      rake libraetd:etd:ingest_optional_etd_deposits >> $LOGGER 2>&1
      res=$?

      # ending message
      logit "Optional deposit import sequence completes with status: $res"
   else
      # idle message
      logit "Not the active host; doing nothing"
   fi

done

# never get here...
exit 0

#
# end of file
#
