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
# determine the logger name
#
function logger_name {
   local name=$1
   if dockerized; then
      DH="unknown"
      if [ -n "$DOCKER_HOST" ]; then
         DH=$(echo $DOCKER_HOST|awk -F. '{print $1}')
      fi
      echo "$APP_HOME/hostfs/logs/$DH.$name"
   else
      echo "/dev/stdout"
   fi
}

#
# log a message with the timestamp
# assumes that $LOGGER is defined
#
function logit {
   local msg=$1
   TS=$(date "+%Y-%m-%d %H:%M:%S")
   echo "$TS: $msg" >> $LOGGER
}

#
# sleep until the provided time
#
function sleep_until {
   local target=$1
   local current_time=$(date "+%H:%M")
   while [ $target != $current_time ]; do
      sleep 59
      current_time=$(date "+%H:%M")
   done
}

#
# determine if we are the active host
#
# Because we run multiple nodes, we have to have one node as the 'master' in the event that processes
# cannot be run concurrently on multiple hosts.
#
# For development, the active host is docker1.lib.virginia.edu.
# For production, the active host is whichever docker host the CNAME librasis.lib.virginia.edu resolves too.
#
function is_active_host {

   # if the docker host variable is not defined
   if [ -z "$DOCKER_HOST" ]; then
      # we cannot determine if we are an active host
      # 1 = false
      return 1
   fi

   DH=$(echo $DOCKER_HOST|awk -F. '{print $1}')
   if [ "$DH" == "docker1" ]; then
      # docker1 is the dev server
      # 0 = true
      return 0
   fi

   # live means this endpoint resolves to our DOCKER_HOST name
   local endpoint="librasis.lib.virginia.edu"

   # setup the appropriate commands depending on our environment
   if dockerized; then
      HOSTINFO="getent hosts"
   else
      HOSTINFO="host"
   fi

   # pull the hostname from the docker host and see if the endpoint resolves to include this host
   REFS=$($HOSTINFO $endpoint|grep $DH|wc -l|awk '{print $1}')

   if [ $REFS -eq 0 ]; then
      # 1 = false
      return 1
   fi

   # 0 = true
   return 0
}

#
# end of file
#
