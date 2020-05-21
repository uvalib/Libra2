#
# common methods between the scripts
#

#
# determine if we are dockerized or not
#
function dockerized {
   if [ -n "$APP_HOME" ]; then
      # 0 = true
      return 0
   else
      # 1 = false
      return 1
   fi
}

#
# log a message
#
function logit {
   local msg=$1
   echo "$msg"
}

#
# sleep until the provided time
#
function sleep_until {
   local target=$1
   local timezone=$2
   local current_time=$(TZ=$timezone date "+%H:%M")
   while [ $target != $current_time ]; do
      sleep 59
      current_time=$(TZ=$timezone date "+%H:%M")
   done
}

#
# determine if we are the active instance
#
# Because we run multiple nodes, we have to have one node as the 'master' in the event that processes
# cannot be run concurrently on multiple instances.
#
function is_active_instance {

   # will determine this at a later date as apropriate

   # 0 = true
   return 0
}

#
# end of file
#
