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
RUN /bin/bash -l -c "gem install json:1.8.3 byebug:8.2.2 ffi:1.9.10 unf_ext:0.0.7.2 posix-spawn:0.3.11 nokogiri:1.6.7.2 websocket-driver:0.6.3 bcrypt:3.1.10 debug_inspector:0.0.2 sqlite3:1.3.11 binding_of_caller:0.7.2 mysql2:0.4.2 --no-ri --no-rdoc"

# attempt to preinstall all dependent gems
RUN /bin/bash -l -c "gem install active-fedora:9.9.0 active-triples:0.7.5 active_attr:0.9.0 activefedora-aggregation:0.8.1 activerecord-import:0.11.0 autoprefixer-rails:6.3.3 blacklight:6.0.1 blacklight-access_controls:0.3.0 blacklight-gallery:0.5.0 blacklight_advanced_search:6.0.1 curation_concerns:0.6.0 curation_concerns-models:0.6.0 devise:3.5.6 domain_name:0.5.20160128 fcrepo_wrapper:0.2.1 font-awesome-rails:4.5.0.1 hydra-access-controls:9.8.0 hydra-collections:7.0.0 hydra-core:9.8.0 hydra-editor:1.2.0 hydra-head:9.8.0 hydra-pcdm:0.4.0 jbuilder:2.4.1 mini_magick:4.4.0 minitest:5.8.4 rails-html-sanitizer:1.0.3 rdoc:4.2.2 rspec-core:3.4.2 rspec-rails:3.4.2 sinatra:1.4.7 solr_wrapper:0.5.0 sprockets-rails:3.0.1 tinymce-rails:4.3.3 twitter-typeahead-rails:0.11.1 warden:1.2.6 actionmailer:4.2.5 actionpack:4.2.5 actionview:4.2.5 active_fedora-noid:1.0.3 activejob:4.2.5 activemodel:4.2.5 activerecord:4.2.5 activeresource:4.0.0 activesupport:4.2.5 acts_as_follower:0.2.1 addressable:2.3.8 arel:6.0.3 autoparse:0.3.3 bcp47:0.3.3 better_errors:2.1.1 blankslate:3.1.3 bootstrap-sass:3.3.6 breadcrumbs_on_rails:2.3.1 browse-everything:0.9.1 builder:3.2.2 bundler:1.11.2 cancancan:1.13.1 carrierwave:0.10.0 coderay:1.1.0 coffee-rails:4.1.1 coffee-script:2.4.1 coffee-script-source:1.10.0 concurrent-ruby:1.0.0 daemons:1.2.3 deprecation:0.2.2 devise-guests:0.5.0 diff-lcs:1.2.5 dropbox-sdk:1.6.5 ebnf:1.0.0 equivalent-xml:0.6.0 erubis:2.7.0 execjs:2.6.0 extlib:0.9.16 faraday:0.9.2 foreigner:1.7.4 globalid:0.3.6 google-api-client:0.8.6 google_drive:1.0.5 googleauth:0.5.1 haml:4.0.7 htmlentities:4.3.4 httmultiparty:0.3.16 http-cookie:1.0.2 http_logger:0.5.1 httparty:0.13.7 hydra-batch-edit:1.1.1 hydra-derivatives:3.0.0 hydra-file_characterization:0.3.3 hydra-works:0.6.0 i18n:0.7.0 jquery-rails:4.1.0 jquery-ui-rails:5.0.5 json-ld:1.99.0 json-schema:2.6.0 jwt:1.5.2 launchy:2.4.3 ldp:0.4.1 legato:0.6.2 link_header:0.0.8 linkeddata:1.99.0 little-plugger:1.1.4 logging:2.0.0 loofah:2.0.3 mail:2.6.3 mail_form:1.5.1 mailboxer:0.13.0 memoist:0.14.0 mime-types:2.99 mimemagic:0.3.1 mini_portile2:2.0.0 mono_logger:1.1.0 multi_json:1.11.2 multi_xml:0.5.5 multipart-post:2.0.0 nest:1.1.2 net-http-persistent:2.9.4 netrc:0.11.0 noid:0.8.0 nom-xml:0.5.4 oauth:0.4.7 oauth2:0.9.4 om:3.1.0 openseadragon:0.2.1 orm_adapter:0.5.0 os:0.9.6 parslet:1.7.1 qa:0.5.0 rack:1.6.4 rack-protection:1.5.3 rack-test:0.6.3 rails:4.2.5 rails-deprecated_sanitizer:1.0.3 rails-dom-testing:1.0.7 rails-observers:0.1.2 rails_autolink:1.1.6 railties:4.2.5 rake:10.5.0 rdf:1.99.1 rdf-aggregate-repo:1.99.0 rdf-isomorphic:1.99.0 rdf-json:1.99.0 rdf-microdata:2.0.2 rdf-n3:1.99.0 rdf-rdfa:1.99.0 rdf-rdfxml:1.99.0 rdf-reasoner:0.3.0 rdf-tabular:0.3.0 rdf-trig:1.99.0.1 rdf-trix:1.99.0 rdf-turtle:1.99.0 rdf-vocab:0.8.7.1 rdf-xsd:1.99.0 redis:3.2.2 redis-namespace:1.5.2 redlock:0.1.5 responders:2.1.1 resque:1.25.2 resque-pool:0.6.0 rest-client:1.8.0 retriable:1.4.1 rsolr:1.0.13 rspec-expectations:3.4.0 rspec-mocks:3.4.1 rspec-support:3.4.1 ruby-box:1.15.0 ruby-progressbar:1.7.5 rubyzip:1.1.7 sass:3.4.21 sass-rails:5.0.4 sdoc:0.4.1 select2-rails:3.5.9.3 signet:0.7.2 simple_form:3.1.1 skydrive:1.2.0 slop:4.2.1 solrizer:3.3.0 sparql:1.99.0 sparql-client:1.99.0 sprockets:3.5.2 stomp:1.3.4 sxp:0.1.5 thor:0.19.1 thread_safe:0.3.5 tilt:2.0.2 tinymce-rails-imageupload:4.0.16.beta turbolinks:2.5.3 tzinfo:1.2.2 uglifier:2.7.2 unf:0.1.4 vegas:0.1.11 xml-simple:1.1.5 yaml_db:0.3.0 --no-ri --no-rdoc"

# create work directory
ENV APP_HOME /libra2
RUN mkdir $APP_HOME

ADD . $APP_HOME

WORKDIR $APP_HOME
RUN /bin/bash -l -c "bundle install"
RUN /bin/bash -l -c "rake db:migrate"

EXPOSE 3000
CMD /bin/bash -l -c "scripts/entry.sh"
