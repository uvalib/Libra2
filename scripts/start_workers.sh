#
# Start the resque-pool and restart it whenever it terminates
#

# source the helper...
DIR=$(dirname $0)
. $DIR/common.sh

# set the appropriate logger
NAME=$(basename $0 .sh)
LOGGER=$(logger_name "$NAME.log")

# define the appropriate resque-pool loggers
STDOUT_LOGGER=$(logger_name "resque-pool.stdout.log")
STDERR_LOGGER=$(logger_name "resque-pool.stderr.log")
LOG_OPT="--stdout $STDOUT_LOGGER --stderr $STDERR_LOGGER"

# set the environment as necessary
if [ -n "$RAILS_ENV" ]; then
   ENV_OPT="--environment $RAILS_ENV"
else
   ENV_OPT=""
fi

# define the time to sleep before attempting a restart
SLEEP_TIME=60

# helpful message...
logit "Starting up..."

# forever...
while true; do

   # determine if we are the active host... run workers on the non-sis host only
   if is_active_host; then

      # ending message
      logit "Starting resque pool..."

      # start up the resque pool
      RUN_AT_EXIT_HOOKS=true TERM_CHILD=1 resque-pool $LOG_OPT $ENV_OPT start
      res=$?

      # ending message
      logit "Resque pool terminates unexpectedly with status: $res; sleeping for $SLEEP_TIME seconds..."

   else
      logit "Not the active host; doing nothing"
   fi

   # sleep for another minute
   sleep $SLEEP_TIME

done

# never get here...
exit 0

#
# end of file
#
