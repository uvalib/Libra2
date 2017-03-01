# remove stale pid files
rm -f $APP_HOME/tmp/pids/resque-pool.pid > /dev/null 2>&1

# start the resque pool daemon
scripts/start_workers.sh
