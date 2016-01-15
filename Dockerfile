FROM centos:7

RUN yum -y update && yum -y install which tar git epel-release && yum -y install nodejs

# install rvm
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN \curl -sSL https://get.rvm.io | /bin/bash -s stable

# install ruby
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.2.4"
RUN /bin/bash -l -c "rvm use 2.2.4 --default"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"

# install some other gems that are slow
RUN /bin/bash -l -c "gem install json:1.8.3 byebug:8.2.1 ffi:1.9.10 unf_ext:0.0.7.1 posix-spawn:0.3.11 nokogiri:1.6.7.1 websocket-driver:0.6.3 bcrypt:3.1.10 debug_inspector:0.0.2 sqlite3:1.3.11 binding_of_caller:0.7.2 --no-ri --no-rdoc"

# create work directory
ENV APP_HOME /libra2
RUN mkdir $APP_HOME

ADD . $APP_HOME

WORKDIR $APP_HOME
RUN /bin/bash -l -c "bundle install"
RUN /bin/bash -l -c "rake db:migrate"

EXPOSE 3000
CMD /bin/bash -l -c "scripts/entry.sh"
