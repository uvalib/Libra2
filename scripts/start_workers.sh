#
# Start the resque-pool
#

# source the helper...
DIR=$(dirname $0)
. $DIR/common.sh

# define the appropriate loggers
export STDOUT_LOGGER=$(logger_name "resque-pool.stdout.log")
export STDERR_LOGGER=$(logger_name "resque-pool.stderr.log")

echo $STDOUT_LOGGER
echo $STDERR_LOGGER

# start up the resque pool
RUN_AT_EXIT_HOOKS=true TERM_CHILD=1 resque-pool --daemon --stdout $STDOUT_LOGGER --stderr $STDERR_LOGGER --environment $RAILS_ENV start

# all good
exit 0

#
# end of file
#
