require_dependency 'libraetd/lib/serviceclient/base_client'

module ServiceClient

   class OrcidAccessClient < BaseClient

     # get the helpers
     #include UrlHelper

     #
     # configure with the appropriate configuration file
     #
     def initialize
       load_config( "orcidaccess.yml" )
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
     # get specified user's ORCID attributes
     #
     def get_attribs_by_cid(id )
       url = "#{self.url}/cid/#{id}?auth=#{self.authtoken}"
       status, response = rest_get( url )
       return status, response['results'][0] if ok?( status ) && response['results'] && response['results'][0]
       return status, ''
     end

     #
     # get all known ORCID attributes
     #
     def get_attribs_all( )
       url = "#{self.url}/cid?auth=#{self.authtoken}"
       status, response = rest_get( url )
       return status, response['results'] if ok?( status ) && response['results']
       return status, ''
     end

     #
     # set specified user's ORCID attributes
     #
     def set_attribs_by_cid(id, orcid, oauth_access, oauth_renew, oauth_scope, user_types )
       url = "#{self.url}/cid/#{id}?auth=#{self.authtoken}"
       payload =  self.construct_attribs_payload( orcid, oauth_access, oauth_renew, oauth_scope, user_types )
       status, _ = rest_put( url, payload )
       return status
     end

     #
     # delete specified user's ORCID attributes
     #
     def del_attribs_by_cid(id)
       url = "#{self.url}/cid/#{id}?auth=#{self.authtoken}"
       status, _ = rest_delete( url )
       return status
     end

     #
     # update user activity (work)
     #
     def set_activity_by_cid( id, work )
       url = "#{self.url}/cid/#{id}/activity?auth=#{self.authtoken}"
       payload =  self.construct_activity_payload( work )
       status, response = rest_put( url, payload )
       return status, response['update_code'] if ok?( status ) && response['update_code']
       return status, ''
     end

     #
     # search ORCID database
     #
     def search_orcid( search, start, max )
       url = "#{self.url}/orcid?q=#{search}&start=#{start}&max=#{max}&auth=#{self.authtoken}"
       status, response = rest_get( url )
       return status, response if ok?( status ) && response['results']
       return status, ''
     end

     #
     # helpers
     #

     #
     # construct the attributes request payload
     #
     def construct_attribs_payload( orcid, oauth_access, oauth_renew, oauth_scope, user_types )
       h = {}

       h['orcid'] = orcid
       h['oauth_access_token'] = oauth_access
       h['oauth_refresh_token'] = oauth_renew
       h['scope'] = oauth_scope
       h['user_types'] = user_types

       #puts "==> #{h.to_json}"
       return h.to_json
     end

     #
     # construct the activity request payload
     #
     def construct_activity_payload( work )
       h = {}

       h['update_code'] = work.orcid_put_code if work.orcid_put_code.present?

       metadata = 'work'
       h[metadata] = {}
       h[metadata]['title'] = work.title.join( ' ' ) if work.title.present?
       h[metadata]['abstract'] = work.description if work.description.present?
       yyyymmdd = ServiceClient.extract_yyyymmdd_from_datestring( work.date_published )
       yyyymmdd = ServiceClient.extract_yyyymmdd_from_datestring( work.date_created ) if yyyymmdd.nil?
       h[metadata]['publication_date'] = yyyymmdd if yyyymmdd.present?
       doi_url = GenericWork.doi_url work.identifier
       h[metadata]['url'] = doi_url if doi_url.present?
       h[metadata]['authors'] = author_cleanup( work )

       type = 'supervised-student-publication'
       if is_phd?(work.degree)
         type = 'dissertation'
       end
       h[metadata]['resource_type'] = type

       #puts "==> #{h.to_json}"
       return h.to_json
     end

     def url
       configuration[ :url ]
     end

     private

     #
     # cleanup author
     # formats the author info
     # author index is set as the doc id for now
     #
     def author_cleanup( doc )
       [{
         index: 0,
         first_name: doc.author_first_name,
         last_name: doc.author_last_name
       }]

     end

     def is_phd?(degree)
       degree ? degree.include?('PHD') : false
     end

     #
     # map the sufia resource type to the ORCID resource type
     #
     #def map_to_orcid_type( resource_type )

     #  case resource_type
     #    when 'Article'
     #  when 'Book'
     #      return 'book'
     #    when 'Conference Proceeding'
     #      return 'conference-paper'
     #    when 'Part of Book'
     #      return 'book-chapter'
     #    when 'Report'
     #      return 'report'
     #    when 'Journal'
     #      return 'journal-issue'
     #    when 'Poster'
     #      return 'conference-poster'
     #    else
     #      return 'other'
     #  end

     #end

   end
end
