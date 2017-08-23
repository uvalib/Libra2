FROM centos:7

# ruby dependancies
RUN yum -y update && yum -y install which tar wget make gcc-c++ zlib-devel libyaml-devel autoconf patch readline-devel libffi-devel openssl-devel bzip2 automake libtool bison sqlite-devel

# install ruby
RUN cd /tmp && wget https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.1.tar.gz
RUN cd /tmp && tar xzvf ruby-2.4.1.tar.gz
RUN cd /tmp/ruby-2.4.1 && ./configure && make && make install
RUN rm -fr /tmp/ruby-2.4.1

# install application dependancies
RUN yum -y install file git epel-release java-1.8.0-openjdk-devel ImageMagick mysql-devel && yum -y install nodejs

# install libreoffice
#RUN cd /tmp && wget https://download.documentfoundation.org/libreoffice/stable/5.3.2/rpm/x86_64/LibreOffice_5.3.2_Linux_x86-64_rpm.tar.gz
#RUN cd /tmp && tar xzfv LibreOffice_5.3.2_Linux_x86-64_rpm.tar.gz
#RUN cd /tmp/LibreOffice_5.3.2.2_Linux_x86-64_rpm/RPMS/ && yum -y localinstall *.rpm
#RUN ln -s /opt/libreoffice5.3/program/soffice /usr/local/bin/soffice

# Create the run user and group
RUN groupadd -r webservice && useradd -r -g webservice webservice && mkdir /home/webservice

# set the timezone appropriatly
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# set the locale correctly
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# install bundler
RUN gem install bundler --no-ri --no-rdoc

# Copy the Gemfile and Gemfile.lock into the image.
# Temporarily set the working directory to where they are.
WORKDIR /tmp
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
RUN bundle install

# create work directory
ENV APP_HOME /libra2
WORKDIR $APP_HOME

ADD . $APP_HOME

# precompile the assets
RUN RAILS_ENV=production SECRET_KEY_BASE=x rake assets:precompile

# Update permissions
RUN chown -R webservice $APP_HOME /home/webservice && chgrp -R webservice $APP_HOME /home/webservice

# Specify the user
USER webservice

# Define port and startup script
EXPOSE 3000
CMD scripts/entry.sh

# Move in other assets
COPY data/container_bash_profile /home/webservice/.profile
