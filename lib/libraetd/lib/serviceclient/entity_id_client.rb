require_dependency 'libraetd/lib/serviceclient/base_client'
require_dependency 'libraetd/app/helpers/url_helper'
require_dependency 'libraetd/lib/serviceclient/orcid_access_client'

module ServiceClient

  class EntityIdClient < BaseClient

    # get the helpers
    include UrlHelper

    RESOURCE_TYPE_DISSERTATION ||= 'Dissertation'
    DC_GENERAL_TYPE_TEXT ||= 'Text'
    UVA_AFFILIATION = {
      name: "University of Virginia",
      schemeUri: "https://ror.org",
      affiliationIdentifier: "https://ror.org/0153tk833",
      affiliationIdentifierScheme: "ROR"
    }

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
      url = "#{self.url}/heartbeat"
      status, _ = rest_get( url )
      return( status )
    end

    #
    # create a new DOI and associate any metadata we can determine from the supplied work
    #
    def newid( work )
      url = "#{self.url}/dois"
      payload =  self.construct_payload( work )
      status, response = rest_post( url, payload )

      new_doi = response.dig('data', 'id')
      return status, "doi:#{new_doi}" if ok?( status ) && new_doi
      return status, ''
    end

    #
    # update an existing DOI with any metadata we can determine from the supplied work
    #
    def metadatasync( work )
      #puts "=====> metadatasync #{work.identifier}"
      url = "#{self.url}/dois/#{work.bare_doi}"
      payload =  self.construct_payload( work, {event: 'publish'})
      status, _ = rest_put( url, payload )
      return status
    end

    #
    # get the details for the specified doi
    #
    def metadataget( doi )
      #puts "=====> metadataget #{doi}"
      url = "#{self.url}/dois/#{doi}"
      status, response = rest_get( url )
      return status, response if ok?( status )
      return status, ''
    end

    #
    # remove a DOI entry
    #
    def remove( doi )
      #puts "=====> remove #{doi}"
      url = "#{self.url}/dois#{doi}"
      status = rest_delete( url )
      return status
    end

    #
    # revoke a DOI entry
    #
    def revoke( doi )
      #puts "=====> revoke #{doi}"
      url = "#{self.url}/dois/#{doi}"
      status, _ = rest_put( url, nil )
      return status
    end

    #
    # construct the request payload
    #
    def construct_payload( work, attributes = {})

      attributes[:prefix] = shoulder.gsub('doi:', '')
      # For a new record, not including a DOI will have Datacite generate one
      attributes[:doi] = work.bare_doi if work.identifier.present?

      attributes[:titles] = [{title: work.title.join(' ')}]
      if work.description.present?
        attributes['descriptions'] = [{
          description: work.description,
          descriptionType: 'Abstract'
        }]
      end

      attributes[:creators] = authors_construct( work )
      attributes[:contributors] = contributors_construct( work )
      attributes[:subjects] = work.keyword.map{|k| {subject: k}} if work.keyword.present?
      attributes[:rightsList] = [{rights: work.rights.first}] if work.rights.present? && work.rights.first.present?
      attributes[:fundingReferences] = work.sponsoring_agency.map{|f| {funderName: f}} if work.sponsoring_agency.present?
      attributes[:types] = {resourceTypeGeneral: DC_GENERAL_TYPE_TEXT, resourceType: RESOURCE_TYPE_DISSERTATION}

      yyyymmdd = extract_yyyymmdd_from_datestring( work.date_published )
      yyyymmdd = extract_yyyymmdd_from_datestring( work.date_created ) if yyyymmdd.blank?
      attributes[:dates] = [{date: yyyymmdd, dateType: 'Issued'}] if yyyymmdd.present?
      attributes[:publicationYear] = yyyymmdd.first(4) if yyyymmdd.present?

      attributes[:url] = fully_qualified_work_url( work.id ) # 'http://google.com'
      attributes[:publisher] = work.publisher if work.publisher.present?

      #puts "==> #{h.to_json}"
      payload = {
        data: {
          type: 'dois',
          attributes: attributes
        }
      }
      puts "#{payload.to_json}"
      return payload.to_json
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
      contributors.sort!{|a,b| a[:index] <=> b[:index]}
      contributors.each {|c| c.except! :index}
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
      return nil if tokens.length < 5
      ix = tokens[ person_index_ix ].to_i
      tokens.each &:chomp!
      return person_construct( ix,
                               tokens[ person_fn_index ],
                               tokens[ person_ln_index ],
                               tokens[ person_cid_index ],
                               tokens[ person_dept_index ],
                               tokens[ person_pub_index ],
                               'RelatedPerson'
                             )
    end

    #
    # construct a json person object from person attributes
    #
    def person_construct( index, fn, ln, cid, dept, institution, type = nil )

      person = {
         index: index,
         givenName: fn,
         familyName: ln,
         nameType: 'Personal'
      }
      person[:contributorType] = type if type.present?
      if institution.present?
        person[:affiliation] = {name: institution}
      end

      if cid.present?
        person[:affiliation] = UVA_AFFILIATION

        # if person has a ORCID account
        orcid_status, orcid_attribs = ServiceClient::OrcidAccessClient.instance.get_attribs_by_cid(cid)

        if orcid_attribs['uri'].present?
          person[:nameIdentifiers] = {
            schemeUri: URI(orcid_attribs['uri']),
            nameIdentifier: orcid_attribs['uri'],
            nameIdentifierScheme: "ORCID"
          }
        elsif orcid_status > 300
          Rails.logger.warn "#{orcid_status} ORCID response during DataCite payload #{orcid_attribs}"
        end
      end


      return person

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
