#
# Runner process to call the rake tasks that control deposit importing from SIS or optional registration
#

# environment settings
if [ -n "$APP_HOME" ]; then
   LOG_ROOT=$APP_HOME/log
   SNAP_ROOT=$APP_HOME/hostfs/snapshot
else
   LOG_ROOT=log
   SNAP_ROOT=tmp
fi

# log file location
export LOG_FILE=$LOG_ROOT/deposit_import.log

# snapshot file for optional ETD
export OPT_SNAPSHOT=$SNAP_ROOT/optional-etd.last

# our sleep time, currently 5 minutes
export SLEEPTIME=300

# the logging function
function logit {
   local msg=$1
   TS=$(date "+%Y-%m-%d %H:%M:%S")
   echo "$TS: $msg" >> $LOG_FILE
}

# helpfull message...
logit "Starting up; using snapshot file $OPT_SNAPSHOT"

# forever...
while true; do

   # sleeping message...
   logit "Sleeping for $SLEEPTIME seconds ..."
   sleep $SLEEPTIME

   # starting message
   logit "Beginning deposit import sequence"

   # do the import
   rake libra2:ingest_optional_etd_deposits $OPT_SNAPSHOT >> $LOG_FILE 2>&1
   res=$?

   # ending message
   logit "Completes with status $res"

done

# never get here...
exit 0

#
# end of file
#
