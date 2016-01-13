# recycle jetty as appropriate
#rake jetty:stop
#rake jetty:start

# start the resque pool daemon
#RUN_AT_EXIT_HOOKS=true TERM_CHILD=1 resque-pool --daemon --environment development stop
RUN_AT_EXIT_HOOKS=true TERM_CHILD=1 resque-pool --daemon --environment development start

# run the server
rails server
