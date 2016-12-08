module PublicHelper

   def file_date(date)
      return "Unknown" if date.nil?
      return date.strftime("%B %d, %Y")
   end

   def file_date_created(date)
      return "Unknown" if date.nil?
      date = date.join() if date.kind_of?(Array)
      return file_date(date) if date.kind_of?(DateTime)
      begin
         return file_date(DateTime.strptime(date, "%Y:%m:%d"))
      rescue
         begin
            return file_date(DateTime.strptime(date, "%m/%d/%Y"))
         rescue
            begin
               return file_date(DateTime.strptime(date, "%Y-%m-%d"))
            rescue
               return date
            end
         end
      end
   end

   def display_title(work)
      return 'Not Found' if work.nil?
      return work[:title][0]
   end

   def display_author( work )
      author = construct_author( work )
      return '' if author.blank?
      #orcid_data = construct_author_orcid( work )
      #orcid_data = content_tag(:span, raw( " #{orcid_data}" ), { style: 'font-weight:normal' }) unless orcid_data.blank?
      orcid_data = ''
      header = raw( "Author:" + orcid_data )
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new( header, author ).render )
   end

   def construct_author( work )
      return '' if work.nil?
      return "#{work.author_last_name}, #{work.author_first_name}, #{work.department}, #{work.author_institution}"
   end

   def construct_author_orcid( work )
      return '' if work.nil?
      return '' if work.author_email.blank?

      orcid = 'http://orcid.org/0000-0002-0566-4186'
      return "#{image_tag 'orcid.png', alt: t('sufia.user_profile.orcid.alt')} #{link_to orcid, orcid, { target: '_blank' }}".html_safe
   end

   def display_advisers(work)
      return '' if work.nil?
      #return '' if work.contributor.blank?
      # special case, we want to show the advisor field as blank
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new("Advisors:", '').render ) if work.contributor.blank?

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
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new("Advisors:", raw( advisors.join( '<br>' ) ) ).render )
   end

   def display_description( description )
      return '' if description.blank?
      description = raw( description.gsub("\n", "<br>"))
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new("Abstract:", description ).render )
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
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new("Sponsoring Agency:", sa ).render )
   end

   def display_related_links( links )
      return '' if links.blank?
      a = []
      links.each { |link|
         display = links.length > 1 ? raw("&bull; #{link}") : link
         a.push( display )
      }
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new("Related Links:", raw( a.join( '<br>' ) ) ).render )
   end

   def display_doi_link(work)
      doi = "Persistent link will appear here after submission." if work.is_draft?
      doi = work.permanent_url unless work.is_draft?
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new("Persistent Link:", doi ).render )
   end

   def display_notes(notes)
    return '' if notes.blank?
      notes = raw( notes.gsub("\n", "<br>"))
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new("Notes:", notes ).render )
   end

   def display_language( language )
      return '' if language.blank?
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new("Language:", language ).render )
   end

   def display_rights(rights)
      return '' if rights.blank?
      rights = rights.join(' ') if rights.kind_of?(Array)
      return( CurationConcerns::Renderers::CustomPublicAttributeRenderer.new("Rights:", rights ).render )
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
end
