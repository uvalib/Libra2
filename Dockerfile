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

# attempt to preinstall all dependent gems
RUN /bin/bash -l -c "gem install \
actionmailer:4.2.6 \
actionpack:4.2.6 \
actionview:4.2.6 \
active-fedora:9.12.0 \
active-triples:0.7.5 \
active_attr:0.9.0 \
active_fedora-noid:1.0.3 \
activejob:4.2.6 \
activemodel:4.2.6 \
activerecord-import:0.13.0 \
activerecord:4.2.6 \
activeresource:4.0.0 \
activesupport:4.2.6 \
acts_as_follower:0.2.1 \
addressable:2.3.8 \
arel:6.0.3 \
autoparse:0.3.3 \
autoprefixer-rails:6.3.6 \
awesome_nested_set:3.0.3 \
babel-source:5.8.35 \
babel-transpiler:0.7.0 \
bcp47:0.3.3 \
bcrypt:3.1.11 \
binding_of_caller:0.7.2 \
blacklight-access_controls:0.3.0 \
blacklight-gallery:0.5.0 \
blacklight:6.1.0 \
blacklight_advanced_search:6.0.2 \
blankslate:3.1.3 \
bootstrap-sass:3.3.6 \
breadcrumbs_on_rails:2.3.1 \
browse-everything:0.10.0 \
builder:3.2.2 \
bundler:1.11.2 \
byebug:8.2.4 \
cancancan:1.13.1 \
carrierwave:0.11.2 \
coffee-rails:4.1.1 \
coffee-script-source:1.10.0 \
coffee-script:2.4.1 \
concurrent-ruby:1.0.1 \
curation_concerns:0.14.0.pre4 \
daemons:1.2.3 \
debug_inspector:0.0.2 \
deprecation:0.2.2 \
devise-guests:0.5.0 \
devise:4.0.0 \
diff-lcs:1.2.5 \
domain_name:0.5.20160310 \
dropbox-sdk:1.6.5 \
ebnf:1.0.0 \
equivalent-xml:0.6.0 \
erubis:2.7.0 \
exception_notification:4.1.4 \
execjs:2.6.0 \
extlib:0.9.16 \
faraday:0.9.2 \
fcrepo_wrapper:0.4.0 \
font-awesome-rails:4.6.2.0 \
foreigner:1.7.4 \
globalid:0.3.6 \
google-api-client:0.8.6 \
google_drive:1.0.6 \
googleauth:0.5.1 \
haml:4.0.7 \
htmlentities:4.3.4 \
httmultiparty:0.3.16 \
http-cookie:1.0.2 \
http_logger:0.5.1 \
httparty:0.13.7 \
hydra-access-controls:9.10.0 \
hydra-batch-edit:2.0.2 \
hydra-core:9.10.0 \
hydra-derivatives:3.0.2 \
hydra-editor:2.0.0 \
hydra-file_characterization:0.3.3 \
hydra-head:9.10.0 \
hydra-pcdm:0.7.0 \
hydra-works:0.9.0 \
i18n:0.7.0 \
jbuilder:2.4.1 \
jquery-rails:4.1.1 \
jquery-ui-rails:5.0.5 \
json-ld:1.99.2 \
json-schema:2.6.1 \
json:1.8.3 \
jwt:1.5.4 \
kaminari:0.16.3 \
kaminari_route_prefix:0.0.1 \
launchy:2.4.3 \
ldp:0.5.0 \
legato:0.7.0 \
link_header:0.0.8 \
linkeddata:1.99.0 \
little-plugger:1.1.4 \
logging:2.1.0 \
loofah:2.0.3 \
mail:2.6.4 \
mail_form:1.5.1 \
mailboxer:0.13.0 \
memoist:0.14.0 \
mime-types:2.99.1 \
mimemagic:0.3.1 \
mini_magick:4.5.1 \
mini_portile2:2.0.0 \
minitest:5.8.4 \
multi_json:1.11.3 \
multi_xml:0.5.5 \
multipart-post:2.0.0 \
mysql2:0.4.4 \
nest:1.1.2 \
net-http-persistent:2.9.4 \
netrc:0.11.0 \
noid:0.8.0 \
nokogiri:1.6.7.2 \
nom-xml:0.5.4 \
oauth2:0.9.4 \
oauth:0.5.1 \
om:3.1.0 \
openseadragon:0.2.1 \
orm_adapter:0.5.0 \
os:0.9.6 \
parslet:1.7.1 \
posix-spawn:0.3.11 \
qa:0.6.0 \
rack-test:0.6.3 \
rack:1.6.4 \
rails-deprecated_sanitizer:1.0.3 \
rails-dom-testing:1.0.7 \
rails-html-sanitizer:1.0.3 \
rails-observers:0.1.2 \
rails:4.2.6 \
rails_autolink:1.1.6 \
railties:4.2.6 \
rake:11.1.2 \
rdf-aggregate-repo:1.99.0 \
rdf-isomorphic:1.99.0 \
rdf-json:1.99.0 \
rdf-microdata:2.0.2 \
rdf-n3:1.99.0 \
rdf-rdfa:1.99.1 \
rdf-rdfxml:1.99.0 \
rdf-reasoner:0.3.0 \
rdf-tabular:0.3.0 \
rdf-trig:1.99.0.1 \
rdf-trix:1.99.0 \
rdf-turtle:1.99.0 \
rdf-vocab:0.8.8 \
rdf-xsd:1.99.0 \
rdf:1.99.1 \
rdoc:4.2.2 \
redis:3.3.0 \
redlock:0.1.5 \
responders:2.1.2 \
rest-client:1.8.0 \
retriable:1.4.1 \
rsolr:1.1.1 \
rspec-core:3.4.4 \
rspec-expectations:3.4.0 \
rspec-mocks:3.4.1 \
rspec-rails:3.4.2 \
rspec-support:3.4.1 \
ruby-box:1.15.0 \
ruby-progressbar:1.8.0 \
rubyzip:1.2.0 \
sass-rails:5.0.4 \
sass:3.4.22 \
sdoc:0.4.1 \
select2-rails:3.5.10 \
signet:0.7.2 \
simple_form:3.1.1 \
skydrive:1.2.0 \
slop:4.3.0 \
solr_wrapper:0.10.0 \
solrizer:3.4.0 \
sparql-client:1.99.0 \
sparql:1.99.1 \
spring:1.7.1 \
sprockets-es6:0.9.0 \
sprockets-rails:3.0.4 \
sprockets:3.6.0 \
stomp:1.3.5 \
sxp:0.1.5 \
thor:0.19.1 \
thread_safe:0.3.5 \
tilt:2.0.2 \
tinymce-rails-imageupload:4.0.16.beta \
tinymce-rails:4.3.8 \
turbolinks:2.5.3 \
twitter-typeahead-rails:0.11.1 \
tzinfo:1.2.2 \
uglifier:3.0.0 \
unf:0.1.4 \
unf_ext:0.0.7.2 \
warden:1.2.6 \
web-console:2.3.0 \
xml-simple:1.1.5 \
yaml_db:0.3.0 \
zeroclipboard-rails:0.0.13 \
--no-ri --no-rdoc"

# Create the run user and group
RUN groupadd -r webservice && useradd -r -g webservice webservice

# create work directory
ENV APP_HOME /libra2
WORKDIR $APP_HOME

ADD . $APP_HOME

RUN /bin/bash -l -c "bundle install"
RUN /bin/bash -l -c "rake db:migrate"
RUN /bin/bash -l -c "rake assets:precompile"

# Update permissions
RUN chown -R webservice $APP_HOME && chgrp -R webservice $APP_HOME

# Specify the user
USER webservice

# Define port and startup script
EXPOSE 3000
CMD /bin/bash -l -c "scripts/entry.sh"
