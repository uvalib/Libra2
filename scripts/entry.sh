RUN_AT_EXIT_HOOKS=true TERM_CHILD=1 resque-pool --daemon --environment development start
rails server
