#
# Runner process to call the rake tasks that control deposit importing from SIS and optional registration
#

# determine if we are in a dockerized environment
if [ -n "$APP_HOME" ]; then
   export LOGGER=$APP_HOME/log/deposit_import.log
else
   export LOGGER=/dev/stdout
fi

# log file location

# our sleep time, currently 5 minutes
export SLEEPTIME=300

# the logging function
function logit {
   local msg=$1
   TS=$(date "+%Y-%m-%d %H:%M:%S")
   echo "$TS: $msg" >> $LOGGER
}

# helpful message...
logit "Starting up..."

# forever...
while true; do

   # sleeping message...
   logit "Sleeping for $SLEEPTIME seconds ..."
   sleep $SLEEPTIME

   # starting message
   logit "Beginning optional deposit import sequence"

   # do the optional import
   bundle exec rake libra2:etd:ingest_optional_etd_deposits >> $LOGGER 2>&1
   res=$?

   # ending message
   logit "Optional deposit import sequence completes with status: $res"

   # starting message
   logit "Beginning SIS deposit import sequence"

   # do the SIS import
   bundle exec rake libra2:etd:ingest_sis_etd_deposits >> $LOGGER 2>&1
   res=$?

   # ending message
   logit "SIS deposit import sequence completes with status: $res"

done

# never get here...
exit 0

#
# end of file
#
