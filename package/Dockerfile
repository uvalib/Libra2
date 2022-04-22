#
#
#
FROM public.ecr.aws/docker/library/ruby:2.6.10-slim-buster

# install application dependancies
RUN apt-get update -qq && apt-get install -y file git imagemagick build-essential nodejs libmariadb-dev clamav clamdscan wget curl software-properties-common

RUN apt-add-repository 'deb http://security.debian.org/debian-security stretch/updates main' && apt-get update -y
RUN apt-get -y install openjdk-8-jre

# see https://stackoverflow.com/questions/52998331/imagemagick-security-policy-pdf-blocking-conversion
RUN cat /etc/ImageMagick-6/policy.xml | egrep -v '"PS"|"PS2"|"PS3"|"EPS"|"PDF"|"XPS"' > /tmp/policy.xml && mv /tmp/policy.xml /etc/ImageMagick-6/policy.xml

# Create the run user and group
RUN groupadd --gid 18570 sse && useradd --uid 1984 -g sse docker

# set the timezone appropriatly
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# set the locale correctly
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# install bundler
RUN gem install bundler -v 2.2.20 --no-document

# create work directory
ENV APP_HOME /libra2
WORKDIR $APP_HOME

# Copy the Gemfile and Gemfile.lock into the image.
ADD Gemfile Gemfile.lock ./
RUN bundle install --jobs=4 --without=["development" "test"] --no-cache

# copy the application
ADD . $APP_HOME

# precompile the assets
RUN RAILS_ENV=production SECRET_KEY_BASE=x rake assets:precompile

# Update permissions
RUN mkdir /home/docker && chown -R docker $APP_HOME /home/docker && chgrp -R sse $APP_HOME /home/docker

# freshen the antivirus definitions and update permissions so we can do this again
RUN sed -i 's/Example/#Example/' /etc/clamav/freshclam.conf
RUN freshclam && chmod -R o+rw /var/lib/clamav /etc/clamav/freshclam.conf

# Define port and startup script
EXPOSE 8080
CMD scripts/entry.sh

# Move in other assets
COPY data/container_bash_profile /home/docker/.profile

# Ensure permissions are correct
RUN chown docker:sse /home/docker/.profile $APP_HOME/scripts/entry.sh && chmod 755 /home/docker/.profile $APP_HOME/scripts/entry.sh

# Add the build tag
ARG BUILD_TAG
RUN test -n "$BUILD_TAG" && touch $APP_HOME/buildtag.build-$BUILD_TAG || touch $APP_HOME/buildtag.build-0

# Specify the user
USER docker

#
# end of file
#
