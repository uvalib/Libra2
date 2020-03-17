require_dependency 'libraetd/lib/serviceclient/base_client'
require_dependency 'libraetd/app/helpers/url_helper'

module ServiceClient

   class EntityIdClient < BaseClient

     # get the helpers
     include UrlHelper

     RESOURCE_TYPE_DISSERTATION ||= 'Dissertation'
     DC_GENERAL_TYPE_TEXT ||= 'Text'

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

       # libra etd now uses the datacite schema
       schema = 'datacite'
       h['schema'] = schema
       h[schema] = {}

       # needed for datacite schema
       h[schema]['abstract'] = work.description if work.description.present?
       h[schema]['creators'] = authors_construct( work )
       h[schema]['contributors'] = contributors_construct( work )
       h[schema]['keywords'] = work.keyword if work.keyword.present?
       h[schema]['rights'] = work.rights.first if work.rights.present? && work.rights.first.present?
       h[schema]['sponsors'] = work.sponsoring_agency if work.sponsoring_agency.present?
       h[schema]['resource_type'] = RESOURCE_TYPE_DISSERTATION
       h[schema]['general_type'] = DC_GENERAL_TYPE_TEXT

       yyyymmdd = extract_yyyymmdd_from_datestring( work.date_published )
       yyyymmdd = extract_yyyymmdd_from_datestring( work.date_created ) if yyyymmdd.nil?
       h[schema]['publication_date'] = yyyymmdd if yyyymmdd
       h[schema]['url'] = fully_qualified_work_url( work.id ) # 'http://google.com'
       h[schema]['title'] = work.title.join( ' ' ) if work.title.present?
       h[schema]['publisher'] = work.publisher if work.publisher.present?

       #puts "==> #{h.to_json}"
       return h.to_json

     end

     #
     # helpers
     #

     def shoulder
       configuration[ :shoulder ]
     end

     def url
       configuration[ :url ]
     end

     private

     def authors_construct( work )

       person = person_construct( 0,
           work.author_first_name.present? ? work.author_first_name : '',
           work.author_last_name.present? ? work.author_last_name : '',
           work.author_email.present? ? User.cid_from_email( work.author_email ) : '',
           work.department.present? ? work.department : '',
           work.author_institution.present? ? work.author_institution : '' )
       return [ person ]
     end

     def contributors_construct( work )

       contributors = []
       work.contributor.each do |c|
         next if c.blank?
         p = person_from_person_string( c )
         contributors << p if p
       end
       return contributors
     end

     #
     # construct a json person object from a contributor string
     #
     def person_from_person_string( person_string )

       # where the values are in the person string
       person_index_ix = 0
       person_cid_index = 1
       person_fn_index = 2
       person_ln_index = 3
       person_dept_index = 4
       person_pub_index = 5

       tokens = person_string.split( "\n" )
       return nil unless tokens.length == 6
       ix = tokens[ person_index_ix ].to_i
       return person_construct( ix,
                                tokens[ person_fn_index ],
                                tokens[ person_ln_index ],
                                tokens[ person_cid_index ],
                                tokens[ person_dept_index ],
                                tokens[ person_pub_index ] )
     end

     #
     # construct a json person object from person attributes
     #
     def person_construct( index, fn, ln, cid, dept, institution )

       return {
           index: index,
           first_name: fn,
           last_name: ln,
           computing_id: cid,
           department: dept,
           institution: institution }

     end

     #
     # attempt to extract YYYY-MM-DD from a date string
     #
     def extract_yyyymmdd_from_datestring( date )

       return nil if date.blank?

       #puts "==> DATE IN [#{date}]"
       begin

         # try yyyy-mm-dd (at the start of the string)
         dts = date.match( /^(\d{4}-\d{1,2}-\d{1,2})/ )
         return dts[ 0 ] if dts

         # try yyyy/mm/dd (at the start of the string)
         dts = date.match( /^(\d{4}\/\d{1,2}\/\d{1,2})/ )
         return dts[ 0 ].gsub( '/', '-' ) if dts

         # try yyyy-mm (at the start of the string)
         dts = date.match( /^(\d{4}-\d{1,2})/ )
         return dts[ 0 ] if dts

         # try yyyy/mm (at the start of the string)
         dts = date.match( /^(\d{4}\/\d{1,2})/ )
         return dts[ 0 ].gsub( '/', '-' ) if dts

         # try mm/dd/yyyy (at the start of the string)
         dts = date.match( /^(\d{1,2}\/\d{1,2}\/\d{4})/ )
         return DateTime.strptime( dts[ 0 ], "%m/%d/%Y" ).strftime( "%Y-%m-%d" ) if dts

         # try yyyy (anywhere in the string)
         dts = date.match( /(\d{4})/ )
         return dts[ 0 ] if dts

       rescue => ex
         #puts "==> EXCEPTION: #{ex}"
         # do nothing...
       end

       # not sure what format
       return nil
     end

   end
end
