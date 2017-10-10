module OrcidHelper

   #
   # per the ORCID license, the best way to show an ORCID
   #
   def display_orcid_from_url( orcid_url )
      return '' if orcid_url.blank?
      return orcid_url.gsub( /https?:\/\//, '' )
   end

   #
   # extract the bare ORCID from the full URL
   #
   def orcid_from_orcid_url( orcid_url )
     return '' if orcid_url.blank?
     tokens = orcid_url.split( "/" )
     return '' if tokens.length == 0
     return tokens[ tokens.length - 1 ]
   end

   #
   # normalize an ORCID URL to the ORCID environment
   # Necessary because sufia *assumes* we are in the orcid.org domain
   # when we might be in the sandbox.orcid.org domain
   #
   def normalize_orcid_url( orcid_url )
     bare_orcid = orcid_from_orcid_url( orcid_url )
     return "#{ENV['ORCID_BASE_URL']}/#{bare_orcid}"
   end

end

#
# end of file
#
