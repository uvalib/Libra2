require_dependency 'libraetd/lib/serviceclient/base_client'
require_dependency 'libraetd/app/helpers/url_helper'

module ServiceClient

   class EntityIdClient < BaseClient

     # get the helpers
     include UrlHelper

     #
     # configure with the appropriate configuration file
     #
     def initialize
       load_config( "entityid.yml" )
     end

     #
     # singleton stuff
     #

     @@instance = new

     def self.instance
       return @@instance
     end

     private_class_method :new

     #
     # check the health of the endpoint
     #
     def healthcheck
       url = "#{self.url}/healthcheck"
       status, _ = rest_get( url )
       return( status )
     end

     #
     # create a new DOI and associate any metadata we can determine from the supplied work
     #
     def newid( work )
       url = "#{self.url}/#{self.shoulder}?auth=#{self.authtoken}"
       payload =  self.construct_payload( work )
       status, response = rest_post( url, payload )

       return status, response['details']['id'] if ok?( status ) && response['details'] && response['details']['id']
       return status, ''
     end

     #
     # update an existing DOI with any metadata we can determine from the supplied work
     #
     def metadatasync( work )
       #puts "=====> metadatasync #{work.identifier}"
       url = "#{self.url}/#{work.identifier}?auth=#{self.authtoken}"
       payload =  self.construct_payload( work )
       status, _ = rest_put( url, payload )
       return status
     end

     #
     # get the details for the specified doi
     #
     def metadataget( doi )
       #puts "=====> metadataget #{doi}"
       url = "#{self.url}/#{doi}?auth=#{self.authtoken}"
       status, response = rest_get( url )
       return status, response['details'] if ok?( status ) && response['details']
       return status, ''
     end

     #
     # remove a DOI entry
     #
     def remove( doi )
       #puts "=====> remove #{doi}"
       url = "#{self.url}/#{doi}?auth=#{self.authtoken}"
       status = rest_delete( url )
       return status
     end

     #
     # revoke a DOI entry
     #
     def revoke( doi )
       #puts "=====> revoke #{doi}"
       url = "#{self.url}/revoke/#{doi}?auth=#{self.authtoken}"
       status, _ = rest_put( url, nil )
       return status
     end

     #
     # construct the request payload
     #
     def construct_payload( work )

       h = {}
       # libra etd uses the crossref schema
       schema = 'crossref'
       h['schema'] = schema
       h[schema] = {}

       h[schema]['url'] = fully_qualified_work_url( work.id )
       h[schema]['title'] = work.title.join( ' ' ) if work.title
       h[schema]['publisher'] = work.publisher if work.publisher
       h[schema]['creator_firstname'] = work.author_first_name if work.author_first_name
       h[schema]['creator_lastname'] = work.author_last_name if work.author_last_name
       h[schema]['creator_department'] = work.department if work.department
       h[schema]['creator_institution'] = work.author_institution if work.author_institution
       h[schema]['publication_date'] = work.date_published if work.date_published
       h[schema]['publication_milestone'] = work.degree if work.degree
       h[schema]['type'] = 'Text'

       #puts "==> #{h.to_json}"

       h.to_json
     end

     #
     # helpers
     #

     def shoulder
       configuration[ :shoulder ]
     end

     def authtoken
       configuration[ :authtoken ]
     end

     def url
       configuration[ :url ]
     end

   end
end
