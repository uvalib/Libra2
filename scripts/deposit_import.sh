#
# Called periodically to import deposit authorizations; either from SIS or the optional ones
#

# send the logs here
if [ -n "$APP_HOME" ]; then
   LOGROOT=$APP_HOME/log
else
   LOGROOT=log
fi

export LOGFILE=$LOGROOT/deposit_import.log

function logit {
   local msg=$1
   TS=$(date "+%Y-%m-%d %H:%M:%S")
   echo "$TS: $msg" >> $LOGFILE
}

# starting message
logit "Beginning deposit import"

# do the import
rake libra2:ingest_optional_etd_deposits >> $LOGFILE 2>&1
res=$?

# ending message
logit "Exists with status $res"

# all over
exit $res

#
# end of file
#
