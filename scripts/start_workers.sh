#!/usr/bin/env bash
#
# Start the worker pool
#

# source the helper...
DIR=$(dirname $0)
. $DIR/common.sh

# define the number of workers
WORKER_COUNT=10
WORKERS_OPT="-c $WORKER_COUNT"

# define the sleep time in the event of a crash
SLEEP_TIME=15

# helpful message...
logit "Starting up..."

while true; do

   # starting message
   logit "INFO: Starting sidekiq with $WORKER_COUNT workers..."

   # start up sidekiq
   sidekiq $WORKERS_OPT
   res=$?

   # ending message
   logit "ERROR: Sidekiq terminates unexpectedly with status: $res; sleeping for $SLEEP_TIME seconds..."

   # sleep for another minute
   sleep $SLEEP_TIME

done

# never get here...
exit 0

#
# end of file
#
