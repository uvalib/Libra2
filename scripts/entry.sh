# start the resque pool daemon
#RUN_AT_EXIT_HOOKS=true TERM_CHILD=1 resque-pool --daemon --environment $RAILS_ENV start

# run the deposit importer process
nohup scripts/deposit_import.sh &

# run the server
rails server -b 0.0.0.0 -p 3000
