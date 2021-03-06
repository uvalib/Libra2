#!/usr/bin/env bash

# remove stale pid file
rm -f $APP_HOME/tmp/pids/server.pid > /dev/null 2>&1

# run the optional deposit importer process
nohup scripts/optional_deposit_import.sh &

# run the SIS deposit importer process
nohup scripts/sis_deposit_import.sh &

# run the sitemap generator process
nohup scripts/sitemap_generator.sh &

# run the server
rails server -b 0.0.0.0 -p 8080 Puma
