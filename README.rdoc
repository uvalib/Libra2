== README

This is the beginning of the Libra 2 project.  

## Dependencies

* ruby v2.2.2 or higher
* latest Bundler gem


## Installation

Clone this project within the cloned Sufia 7 alpha on your local machine.  In the directory to which you cloned it, run the following:

```ruby
git clone git@github.com:projecthydra/sufia.git
cd sufia
bundle install
rake jetty:clean
rake curation_concerns:jetty:config
rake jetty:start
git clone git@github.com:uvalib/Libra2.git
cd Libra2
bundle install
rake db:migrate
redis-server
RUN_AT_EXIT_HOOKS=true TERM_CHILD=1 resque-pool --daemon --environment development start
rails server
```

You should now be able to open your browser to http://localhost:3000/
