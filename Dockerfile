FROM centos:7

RUN yum -y update && yum -y install which tar file git epel-release java-1.8.0-openjdk-devel ImageMagick mysql-devel && yum -y install nodejs

# install rvm
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN \curl -sSL https://get.rvm.io | /bin/bash -s stable

# install ruby
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.3.0"
RUN /bin/bash -l -c "rvm use 2.3.0 --default"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"

# set the timezone appropriatly
ENV TZ=EST5EDT
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# set the locale correctly
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# Create the run user and group
RUN groupadd -r webservice && useradd -r -g webservice webservice && mkdir /home/webservice

# Copy the Gemfile and Gemfile.lock into the image and temporarily set the working directory to where they are.
WORKDIR /tmp
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
ADD vendor/gems vendor/gems
RUN /bin/bash -l -c "bundle install"

# create work directory
ENV APP_HOME /libra2
WORKDIR $APP_HOME

ADD . $APP_HOME

RUN /bin/bash -l -c "rake assets:precompile"

# Update permissions
RUN chown -R webservice $APP_HOME /home/webservice && chgrp -R webservice $APP_HOME /home/webservice

# Specify the user
USER webservice

# Define port and startup script
EXPOSE 3000
CMD /bin/bash -l -c "scripts/entry.sh"

# move in the profile
COPY data/container_bash_profile /home/webservice/.profile
