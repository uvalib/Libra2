# LIBRA 2  [![Build Status](https://travis-ci.org/uvalib/Libra2.svg?branch=develop)](https://travis-ci.org/uvalib/Libra2)

Online Archive of University of Virginia Scholarship. 
This repository contains Sufia code and the second major release of the Libra project.  

## Dependencies
* Ruby v2.2.2 or higher
* latest Bundler gem

## Installation

Fire up a console and type:

`$ git clone git@github.com:uvalib/Libra2.git` 

Then run a bundle install

`$ bundle install` 

Then create the database and Redis

`$ rake db:migrate`
`$ redis-server`

Then run hooks and fire up the server

`$ RUN_AT_EXIT_HOOKS=true TERM_CHILD=1 resque-pool --daemon --environment development start`
`$ rails s`

```
You should now be able to open your browser to http://localhost:3000/
