#
# Runner process to call the rake tasks that control deposit importing from SIS or optional registration
#

# send the logs here
if [ -n "$APP_HOME" ]; then
   LOGROOT=$APP_HOME/log
else
   LOGROOT=log
fi

export LOGFILE=$LOGROOT/deposit_import.log

# our sleep time, currently 5 minutes
export SLEEPTIME=300

# the logging function
function logit {
   local msg=$1
   TS=$(date "+%Y-%m-%d %H:%M:%S")
   echo "$TS: $msg" >> $LOGFILE
}

# forever...
while true; do

   # sleeping message...
   logit "Sleeping for $SLEEPTIME seconds ..."
   sleep $SLEEPTIME

   # starting message
   logit "Beginning deposit import"

   # do the import
   rake libra2:ingest_optional_etd_deposits >> $LOGFILE 2>&1
   res=$?

   # ending message
   logit "Completes with status $res"

done

# never get here...
exit 0

#
# end of file
#
