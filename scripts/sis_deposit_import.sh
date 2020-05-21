#!/usr/bin/env bash
#
# Runner process to call the rake tasks that control deposit importing from SIS
#

# source the helper...
DIR=$(dirname $0)
. $DIR/common.sh

# our sleep time, currently 5 minutes
export SLEEPTIME=300

# helpful message...
logit "INFO: SIS deposit import starting up..."

# forever...
while true; do

   # sleeping message...
   logit "INFO: Sleeping for $SLEEPTIME seconds..."
   sleep $SLEEPTIME

   # determine if we are the active instance... only run on one instance even though we may be deployed on many
   if is_active_instance; then

      # starting message
      logit "INFO: Beginning SIS deposit import sequence"

      # do the SIS import
      rake libraetd:sisetd:ingest_sis_etd_deposits
      res=$?

      # ending message
      logit "INFO: SIS deposit import sequence completes with status: $res"
   else
      # idle message
      logit "INFO: Not the active instance; doing nothing"
   fi

done

# never get here...
exit 0

#
# end of file
#
