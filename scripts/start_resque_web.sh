#
# used to start the resque-web application for monitoring the resque queues
#

# source the helper...
DIR=$(dirname $0)
. $DIR/common.sh

# define the appropriate resque-pool loggers
LOGGER=$(logger_name "resque-web.log")
LOG_OPT="--log-file $LOGGER"

# some local definitions
rails_root=${RAILS_ROOT:-.}
port=8001
conf=$rails_root/config/initializers/resque_config.rb

# ending message
logit "Starting resque pool monitoring application ..."

# start the monitoring app
resque-web -L --debug $LOG_OPT -p $port $conf
