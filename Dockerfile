FROM centos:7

RUN yum -y update
RUN yum -y install which tar git epel-release

# install rvm
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN \curl -sSL https://get.rvm.io | /bin/bash -s stable

# install ruby
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.2.4"
RUN /bin/bash -l -c "rvm use 2.2.4 --default"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"

# other dependancies
RUN yum -y install nodejs

# dont change often so move them here
EXPOSE 3000
CMD /bin/bash -l -c "scripts/entry.sh"

# create work directory
ENV APP_HOME /libra2
RUN mkdir $APP_HOME

ADD . $APP_HOME

WORKDIR $APP_HOME
RUN /bin/bash -l -c "bundle install"
RUN /bin/bash -l -c "rake db:migrate"
