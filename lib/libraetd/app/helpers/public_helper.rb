module PublicHelper

   def file_date(date)
      return "Unknown" if date.nil?
      return date.in_time_zone.strftime("%B %d, %Y")
   end

   def file_date_created(date)
      return "Unknown" if date.nil?
      date = date.join() if date.kind_of?(Array)
      return file_date(date) if date.kind_of?(DateTime)
      begin
        return file_date(Date.strptime(date, "%Y:%m:%d"))
      rescue
         begin
           return file_date(Date.strptime(date, "%m/%d/%Y"))
         rescue
            begin
              return file_date(Date.strptime(date, "%Y-%m-%d"))
            rescue
               return date
            end
         end
      end
   end


   def display_title(work)
      return 'Not Found' if work.nil? || work[:title].nil? || work[:title][0].nil?
      return raw( work[:title][0] )
   end

   def display_author( work )
      author = construct_author( work )
      return '' if author.blank?
      orcid_data = construct_author_orcid( work )
      orcid_data = content_tag(:span, raw( " #{orcid_data}" ), { style: 'font-weight:normal' }) unless orcid_data.blank?
      header = raw( "Author:" + orcid_data )
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new( header, author ).render )
   end

   def construct_author( work )
      return '' if work.nil?
      author_display = "#{work.author_last_name}, #{work.author_first_name}"
      author_display += ", #{work.department}" if work.department.present?
      author_display += ", #{work.author_institution}" if work.author_institution.present?
      author_display
   end

   def construct_author_orcid( work )
      return '' if work.nil?
      return '' if work.author_email.blank?

      orcid = get_author_orcid( work )
      return '' if orcid.blank?

      return "#{image_tag 'orcid.png', alt: t('sufia.user_profile.orcid.alt')} #{link_to display_orcid_from_url( normalize_orcid_url( orcid ) ), normalize_orcid_url( orcid ), { target: '_blank' }}".html_safe
   end

   def display_advisers(work)
      return '' if work.nil?
      #return '' if work.contributor.blank?
      # special case, we want to show the advisor field as blank
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new("Advisor:", '').render ) if work.contributor.blank?

      # advisers are tagged with a numeric index so sorting them ensures they are presented in the correct order
      contributors = work.contributor.sort
      advisors = []

      contributors.each { |contributor|
         arr = contributor.split("\n")
         arr.push('') if arr.length == 4 # if the last item is empty, the split command will miss it.
         arr.push('') if arr.length == 5 # if the last item is empty, the split command will miss it.
         # arr should be an array of [ index, computing_id, first_name, last_name, department, institution ]
         if arr.length == 6
            advisors.push( construct_advisor_line( arr ) )
         else
            advisors.push(contributor) # this shouldn't happen, but perhaps it will if old data gets in there.
         end
      }
      label = 'Advisor'.pluralize( advisors.length )
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new("#{label}:", raw( advisors.join( '<br>' ) ) ).render )
   end

   def display_description( description )
      return '' if description.blank?
      description = simple_format( description )
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new("Abstract:", raw( description ) ).render )
   end

   def display_degree( degree )
      return '' if degree.blank?
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new("Degree:", degree ).render )
   end

   def display_keywords( work )
      kw = construct_keywords( work )
      return '' if kw.blank?
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new("Keywords:", kw ).render )
   end

   def construct_keywords( work )
      return '' if work.nil?
      return work.keyword.join( ', ')
   end

   def display_sponsoring_agency( sponsoring_agency )
      return '' if sponsoring_agency.blank?
      sa = sponsoring_agency.join( ' ')
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new("Sponsoring Agency:", sponsoring_agency ).render )
   end

   def display_related_links( links )
      return '' if links.blank?
      links = links.map do |link|
         content_tag :li, link
      end

      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new("Related Links:", links ).render )
   end

   def display_doi_link(work)
      doi = if work.is_draft?
         "Persistent link will appear here after submission."
      elsif work.identifier
         work.permanent_url
      else
         "Still working on assigning a DOI. This is the public URL: #{public_view_url(work.id)}"
      end
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new("Persistent Link:", doi ).render )
   end

   def display_notes(notes)
    return '' if notes.blank?
      notes = simple_format( notes )
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new("Notes:", notes ).render )
   end

   def display_language( language )
      return '' if language.blank?
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new("Language:", language ).render )
   end

   def display_rights(rights)
      return '' if rights.blank?
      rights = rights_link rights
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new("Rights:", rights ).render )
   end

   def rights_link value
      value = value.try(:first) || value
      license = CurationConcerns::QaSelectService.new('rights').authority.find(value)
      license = {'term' => value} unless license.present?

      if license['url'].present?
        link_to(license['term'], license['url'], target: '_blank')
      else
        license['term']
      end
   end

   def display_publication_date( date )
      return '' if date.blank?
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new("Issued Date:", date.gsub( '-', '/' ) ).render )
   end

   def display_array(value)
      if value.kind_of?(Array)
         value = value.join(", ")
      end
      return value
   end

  def construct_advisor_line( arr )
     res = ""
     res = field_append( res, arr[3].strip )
     res = field_append( res, arr[2].strip )
     res = field_append( res, arr[4].strip )
     res = field_append( res, arr[5].strip )
     return( res )
  end

  def field_append( current, field )
     res = current
     if field.blank? == false
        res += ", " if res.blank? == false
        res += field
     end
     return res
  end

  #
  # make the filename safe for download by removing any characters that might cause problems
  #
  def safe_filename( filename )
    ret = filename

    # remove commas
    ret = ret.gsub( /,/, '' )

    # remove colons
    ret = ret.gsub( /:/, '' )

    # change spaces to underscores
    ret = ret.gsub( / /, '_' )

    return ret
  end
end
