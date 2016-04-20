# start the resque pool daemon
RUN_AT_EXIT_HOOKS=true TERM_CHILD=1 resque-pool --daemon --environment $RAILS_ENV start

# install the crontabs required
crontab scripts/deposit_import.crontab

# run the server
rails server -b 0.0.0.0 -p 3000
