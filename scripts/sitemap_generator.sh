#
# Runner process to generate the sitemap on a nightly basis
#

# source the helper...
DIR=$(dirname $0)
. $DIR/common.sh

# set the appropriate logger
export NAME=$(basename $0 .sh)
export LOGGER=$(logger_name "$NAME.log")

# the time we want the action to occur
# this is the time in EST
#export ACTION_TIME="00:30"
# we are running in UTC
export ACTION_TIME="04:30"

# helpful message...
logit "Sitemap generator starting up..."

# forever...
while true; do

   # sleeping message...
   logit "Sleeping until $ACTION_TIME..."
   sleep_until $ACTION_TIME

   # starting message
   logit "Beginning sitemap generator sequence"

   if [ "$ENABLE_TEST_FEATURES" == "n" ]; then
      rake sitemap:refresh >> $LOGGER 2>&1
   else
      rake sitemap:refresh:no_ping >> $LOGGER 2>&1
   fi
   res=$?

   # ending message
   logit "Sitemap generator completes with status: $res"

   # sleep for another minute
   sleep 60

done

# never get here...
exit 0

#
# end of file
#
