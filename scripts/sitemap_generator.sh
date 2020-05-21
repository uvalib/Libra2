#
# Runner process to generate the sitemap on a nightly basis
#

# source the helper...
DIR=$(dirname $0)
. $DIR/common.sh

# the time we want the action to occur
# this is specified in localtime
export ACTION_TIME="00:30"
export ACTION_TIMEZONE="America/New_York"

# helpful message...
logit "INFO: Sitemap generator starting up..."

# forever...
while true; do

   # sleeping message...
   logit "INFO: Sleeping until $ACTION_TIME $ACTION_TIMEZONE..."
   sleep_until $ACTION_TIME $ACTION_TIMEZONE

   # starting message
   logit "INFO: Beginning sitemap generator sequence"

   if [ "$ENABLE_TEST_FEATURES" == "n" ]; then
      rake sitemap:refresh 
   else
      rake sitemap:refresh:no_ping
   fi
   res=$?

   # ending message
   logit "INFO: Sitemap generator completes with status: $res"

   # sleep for another minute
   sleep 60

done

# never get here...
exit 0

#
# end of file
#
