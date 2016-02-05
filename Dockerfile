FROM centos:7

RUN yum -y update && yum -y install which tar git epel-release java-1.8.0-openjdk-devel ImageMagick mysql-devel && yum -y install nodejs

# install rvm
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN \curl -sSL https://get.rvm.io | /bin/bash -s stable

# install ruby
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.2.4"
RUN /bin/bash -l -c "rvm use 2.2.4 --default"
RUN /bin/bash -l -c "gem install bundler --no-ri --no-rdoc"

# install some other gems that are slow
RUN /bin/bash -l -c "gem install json:1.8.3 byebug:8.2.1 ffi:1.9.10 unf_ext:0.0.7.1 posix-spawn:0.3.11 nokogiri:1.6.7.1 websocket-driver:0.6.3 bcrypt:3.1.10 debug_inspector:0.0.2 sqlite3:1.3.11 binding_of_caller:0.7.2 mysql2:0.4.2 --no-ri --no-rdoc"

# attempt to preinstall all dependent gems
RUN /bin/bash -l -c "gem install rake:10.5.0 i18n:0.7.0 minitest:5.8.3 thread_safe:0.3.5 builder:3.2.2 erubis:2.7.0 rack:1.6.4 mime-types:2.99 multi_json:1.11.2 link_header:0.0.8 htmlentities:4.3.4 tilt:2.0.2 sxp:0.1.5 addressable:2.3.8 net-http-persistent:2.9.4 multipart-post:2.0.0 http_logger:0.5.1 slop:4.2.1 daemons:1.2.3 stomp:1.3.4 xml-simple:1.1.5 noid:0.8.0 arel:6.0.3 acts_as_follower:0.2.1 extlib:0.9.16 execjs:2.6.0 coderay:1.1.0 sass:3.4.21 thor:0.19.1 concurrent-ruby:1.0.0 blankslate:3.1.3 breadcrumbs_on_rails:2.3.1 jwt:1.5.2 little-plugger:1.1.4 memoist:0.14.0 os:0.9.6 retriable:1.4.1 oauth:0.4.7 multi_xml:0.5.5 mimemagic:0.3.1 cancancan:1.13.1 cliver:0.3.2 coffee-script-source:1.10.0 safe_yaml:1.0.4 logger:1.2.8 rubyzip:1.1.7 mini_magick:4.3.6 netrc:0.11.0 redis:3.2.2 mono_logger:1.1.0 database_cleaner:1.5.1 orm_adapter:0.5.0 diff-lcs:1.2.5 fakeweb:1.3.0 rspec-support:3.4.1 ruby-progressbar:1.7.5 hashdiff:0.2.3 vcr:3.0.1 bcp47:0.3.3 dropbox-sdk:1.6.5 rdoc:4.2.1 tzinfo:1.2.2 rsolr:1.0.13 rack-test:0.6.3 rack-protection:1.5.3 vegas:0.1.11 warden:1.2.4 mail:2.6.3 legato:0.6.2 rdf:1.99.1 haml:4.0.7 launchy:2.4.3 json-schema:2.6.0 faraday:0.9.2 autoparse:0.3.3 autoprefixer-rails:6.2.3 uglifier:2.7.2 better_errors:2.1.1 select2-rails:3.5.9.3 sprockets:3.5.2 parslet:1.7.1 logging:2.0.0 httparty:0.13.7 childprocess:0.5.9 coffee-script:2.4.1 crack:0.4.3 unf:0.1.4 redlock:0.1.5 redis-namespace:1.5.2 nest:1.1.2 rspec-core:3.4.1 rspec-expectations:3.4.0 rspec-mocks:3.4.1 sdoc:0.4.1 activesupport:4.2.5 loofah:2.0.3 equivalent-xml:0.6.0 xpath:2.0.0 webrat:0.7.3 sinatra:1.4.6 json-ld:1.99.0 rdf-aggregate-repo:1.99.0 rdf-isomorphic:1.99.0 rdf-json:1.99.0 rdf-xsd:1.99.0 rdf-n3:1.99.0 ebnf:1.0.0 rdf-vocab:0.8.7.1 rdf-trix:1.99.0 sparql-client:1.99.0 signet:0.7.2 oauth2:0.9.4 bootstrap-sass:3.3.6 httmultiparty:0.3.16 webmock:1.22.6 domain_name:0.5.25 rspec:3.4.0 rails-deprecated_sanitizer:1.0.3 globalid:0.3.6 activemodel:4.2.5 deprecation:0.2.2 nom-xml:0.5.4 solrizer:3.3.0 jettywrapper:2.0.3 hydra-file_characterization:0.3.3 factory_girl:4.5.0 jbuilder:2.4.0 rails-html-sanitizer:1.0.2 capybara:2.5.0 resque:1.25.2 rdf-microdata:2.0.2 rdf-rdfa:1.99.0 rdf-turtle:1.99.0 rdf-tabular:0.3.0 sparql:1.99.0 googleauth:0.5.1 ruby-box:1.15.0 skydrive:1.2.0 http-cookie:1.0.2 fuubar:2.0.0 rails-dom-testing:1.0.7 activejob:4.2.5 active_attr:0.8.5 activerecord:4.2.5 rails-observers:0.1.2 carrierwave:0.10.0 rspec-activemodel-mocks:1.0.2 om:3.1.0 poltergeist:1.8.1 resque-pool:0.6.0 rdf-rdfxml:1.99.0 rdf-reasoner:0.3.0 rdf-trig:1.99.0.1 google-api-client:0.8.6 rest-client:1.8.0 actionview:4.2.5 activerecord-import:0.10.0 foreigner:1.7.4 activeresource:4.0.0 linkeddata:1.99.0 google_drive:1.0.5 actionpack:4.2.5 active-triples:0.7.3 ldp:0.4.1 actionmailer:4.2.5 railties:4.2.5 sprockets-rails:3.0.0 simple_form:3.1.1 active-fedora:9.7.0 mail_form:1.5.1 font-awesome-rails:4.5.0.0 coffee-rails:4.1.1 jquery-ui-rails:5.0.5 responders:2.1.1 jquery-rails:4.1.0 rspec-rails:3.4.0 tinymce-rails:4.3.2 rails:4.2.5 sass-rails:5.0.4 active_fedora-noid:1.0.3 activefedora-aggregation:0.8.0 hydra-derivatives:3.0.0 turbolinks:2.5.3 devise:3.5.3 tinymce-rails-imageupload:4.0.16.beta blacklight:5.17.2 openseadragon:0.2.1 qa:0.5.0 hydra-editor:1.1.1 rails_autolink:1.1.6 mailboxer:0.13.0 yaml_db:0.3.0 browse-everything:0.9.1 hydra-pcdm:0.3.1 devise-guests:0.5.0 blacklight_advanced_search:5.2.1 hydra-access-controls:9.5.0 blacklight-gallery:0.4.0 hydra-works:0.6.0 hydra-core:9.5.0 hydra-head:9.5.0 hydra-collections:6.0.0 hydra-batch-edit:1.1.1 --no-ri --no-rdoc"

# create work directory
ENV APP_HOME /libra2
RUN mkdir $APP_HOME

ADD . $APP_HOME

WORKDIR $APP_HOME
RUN /bin/bash -l -c "bundle install"
RUN /bin/bash -l -c "rake db:migrate"

EXPOSE 3000
CMD /bin/bash -l -c "scripts/entry.sh"
