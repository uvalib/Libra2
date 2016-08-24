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

# attempt to preinstall dependent gems with native extensions
RUN /bin/bash -l -c "gem install \
bcrypt:3.1.11 \
debug_inspector:0.0.2 \
byebug:9.0.5 \
unf_ext:0.0.7.2 \
mysql2:0.4.4 \
posix-spawn:0.3.11 \
nokogiri:1.6.8 \
binding_of_caller:0.7.2 \
hiredis:0.6.1 \
--no-ri --no-rdoc"

# set the timezone appropriatly
ENV TZ=EST5EDT
RUN cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Create the run user and group
RUN groupadd -r webservice && useradd -r -g webservice webservice && mkdir /home/webservice

# create work directory
ENV APP_HOME /libra2
WORKDIR $APP_HOME

ADD . $APP_HOME

RUN /bin/bash -l -c "bundle install"
RUN /bin/bash -l -c "rake db:migrate"
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
