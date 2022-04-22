#!/usr/bin/env bash

# remove stale pid file
rm -f $APP_HOME/tmp/pids/server.pid > /dev/null 2>&1

# run the optional deposit importer process
scripts/optional_deposit_import.sh &

# run the SIS deposit importer process
scripts/sis_deposit_import.sh &

# run the sitemap generator process
scripts/sitemap_generator.sh &

# run the server
bundle exec rails server -b 0.0.0.0 -p 8080 Puma
