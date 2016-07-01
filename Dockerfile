FROM alpine:3.4

# Add necessary packages
RUN apk --update add bash tzdata ruby ruby-dev build-base nodejs mariadb-dev zlib-dev libxml2-dev libxslt-dev imagemagick openjdk8-jre-base

# Add base gems
RUN gem install bundler io-console --no-ri --no-rdoc

# attempt to preinstall dependent gems with native extensions
RUN gem install \
json:1.8.3 \
bcrypt:3.1.11 \
debug_inspector:0.0.2 \
byebug:9.0.5 \
unf_ext:0.0.7.2 \
mysql2:0.4.4 \
posix-spawn:0.3.11 \
nokogiri:1.6.8 \
binding_of_caller:0.7.2 \
bigdecimal:1.2.7 \
--no-ri --no-rdoc

# set the timezone appropriatly
ENV TZ=EST5EDT
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Create the run user and group
RUN addgroup webservice && adduser webservice -G webservice -D

# create work directory
ENV APP_HOME /libra2
WORKDIR $APP_HOME

ADD . $APP_HOME
#RUN rm $APP_HOME/Gemfile.lock
RUN bundle install
RUN rake db:migrate
RUN rake assets:precompile

# Update permissions
RUN chown -R webservice $APP_HOME && chgrp -R webservice $APP_HOME

# Specify the user
USER webservice

# Define port and startup script
EXPOSE 3000
CMD scripts/entry.sh
