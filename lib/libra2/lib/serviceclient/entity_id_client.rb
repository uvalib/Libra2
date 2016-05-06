require_dependency 'libra2/lib/serviceclient/base_client'

module ServiceClient

   class EntityIdClient < BaseClient

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
     # remove a DOI entry
     #
     def remove( work )
       # not implemented
       500
     end

     #
     # construct the request payload
     #
     def construct_payload( work )
       h = {}
       h['title'] = work.title[ 0 ] if work.title && work.title[ 0 ]
       h['publisher'] = work.publisher if work.publisher
       h['creator'] = work.creator if work.creator
       h['url'] = self.fully_qualified_work_url( work.id )
       h['publication_year'] = "#{work.date_uploaded.year}" if work.date_uploaded
       h['type'] = work.resource_type if work.resource_type
       puts "====> #{h}"
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

     # TODO-DPG: use the helper...
     def fully_qualified_work_url( id )
       return "#{self.public_site_url}/public_view/#{id}" unless id.nil?
       return public_site_url
     end

     def public_site_url
       #TODO-DPG: fix this appropriatly
       "https://libra2dev.lib.virginia.edu"
     end

   end
end
