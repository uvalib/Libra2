require_dependency 'libra2/lib/serviceclient/base_client'
require_dependency 'libra2/app/helpers/url_helper'

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
       status, response = rest_send( url, :post, payload )

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
       status, _ = rest_send( url, :put, payload )
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
     # construct the request payload
     #
     def construct_payload( work )
       h = {}
       h['title'] = work.title[ 0 ] if work.title && work.title[ 0 ]
       h['publisher'] = work.publisher if work.publisher
       h['creator'] = "#{work.author_last_name}, #{work.author_first_name}" if work.creator
       h['url'] = fully_qualified_work_url( work.id )
       h['affiliation'] = "#{work.department} #{work.author_institution}"
       h['publication_year'] = "#{work.date_created.split("/")[0]}" if work.date_created
       h['type'] = "Text/Dissertation" # work.resource_type if work.resource_type
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
