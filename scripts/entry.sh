# remove stale pid files
rm -f $APP_HOME/tmp/pids/resque-pool.pid > /dev/null 2>&1
rm -f $APP_HOME/tmp/pids/server.pid > /dev/null 2>&1

# start the resque pool daemon
nohup scripts/start_workers.sh &

# start the resque monitor application
scripts/start_resque_web.sh

# run the deposit importer process
nohup scripts/deposit_import.sh &

# run the SIS exporter process
nohup scripts/sis_export.sh &

# run the SIS importer process
nohup scripts/sis_import.sh &

# run the statistics rollup process
nohup scripts/stats_rollup.sh &

# run the server
rails server -b 0.0.0.0 -p 3000 Puma
