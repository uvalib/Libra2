Sufia.config do |config|

  config.register_curation_concern :generic_work

  # Email recipient of messages sent via the contact form
  # config.contact_email = "repo-admin@example.org"

  # Text prefacing the subject entered in the contact form
  # config.subject_prefix = "Contact form:"

  # How many notifications should be displayed on the dashboard
  # config.max_notifications_for_dashboard = 5

  # How frequently should a file be audited.
  # config.max_days_between_audits = 7

  # Enable displaying usage statistics in the UI
  # Defaults to FALSE
  # Requires a Google Analytics id and OAuth2 keyfile.  See README for more info
  config.analytics = false

  # Specify a Google Analytics tracking ID to gather usage statistics
  # config.google_analytics_id = 'UA-99999999-1'

  # Specify a date you wish to start collecting Google Analytic statistics for.
  # config.analytic_start_date = DateTime.new(2014,9,10)

  # Enables a link to the citations page for a generic_file.
  # Default is false
  # config.citations = false

  # Where to store tempfiles, leave blank for the system temp directory (e.g. /tmp)
  config.temp_file_base = File.join( Rails.root, 'hostfs', 'tmp' )

  # Specify the form of hostpath to be used in Endnote exports
  # config.persistent_hostpath = 'http://localhost/files/'

  # If you have ffmpeg installed and want to transcode audio and video uncomment this line
  config.enable_ffmpeg = true

  config.ffmpeg_path = "#{Rails.application.root}/tools/ffmpeg-3.2.3-64bit-static/ffmpeg"

  # Sufia uses NOIDs for files and collections instead of Fedora UUIDs
  # where NOID = 10-character string and UUID = 32-character string w/ hyphens
  # config.enable_noids = true

  # Specify a different template for your repository's NOID IDs
  # config.noid_template = ".reeddeeddk"

  # Store identifier minter's state in a file for later replayability
  config.minter_statefile = File.join( Rails.root, 'hostfs', 'state', 'minter-state' )

  # Specify the prefix for Redis keys:
  # config.redis_namespace = "sufia"

  # Specify the path to the file characterization tool:
  config.fits_path = "#{Rails.application.root}/tools/fits-1.2.0/fits.sh"

  # Specify the path to the file derivatives creation tool:
  # config.libreoffice_path = "soffice"

  # Specify how many seconds back from the current time that we should show by default of the user's activity on the user's dashboard
  # config.activity_to_show_default_seconds_since_now = 24*60*60

  # Sufia can integrate with Zotero's Arkivo service for automatic deposit
  # of Zotero-managed research items.
  # config.arkivo_api = false

  # Specify a date you wish to start collecting Google Analytic statistics for.
  # Leaving it blank will set the start date to when ever the file was uploaded by
  # NOTE: if you have always sent analytics to GA for downloads and page views leave this commented out
  # config.analytic_start_date = DateTime.new(2014,9,10)

  # Location autocomplete uses geonames to search for named regions.
  # Specify the user for connecting to geonames:
  # config.geonames_username = ''

  # Should the acceptance of the licence agreement be active (checkbox), or
  # implied when the save button is pressed? Set to true for active.
  # The default is true.
  # config.active_deposit_agreement_acceptance = true

  # Should work creation require file upload, or can a work be created first
  # and a file added at a later time?
  # The default is true.
  # config.work_requires_files = true

  # Should a button with "Share my work" show on the front page to all users (even those not logged in)?
  # config.always_display_share_button = true

  # The user who runs batch jobs. Update this if you aren't using emails
  # config.batch_user_key = 'batchuser@example.com'

  # The user who runs audit jobs. Update this if you aren't using emails
  # config.audit_user_key = 'audituser@example.com'
  #
  # The banner image. Should be 5000px wide by 1000px tall.
  # config.banner_image = 'https://cloud.githubusercontent.com/assets/92044/18370978/88ecac20-75f6-11e6-8399-6536640ef695.jpg'

  # Temporary path to hold uploads before they are ingested into FCrepo.
  # These must be lambdas that return a Pathname. Can be configured separately
  config.upload_path = ->() { Rails.root + 'hostfs' + 'uploads' + 'tmp' }
  #config.cache_path = ->() { Rails.root + 'hostfs' + 'uploads' + 'cache' }
  #config.cache_path = ->() { '/tmp' }

  # Location on local file system where derivatives will be stored.
  # If you use a multi-server architecture, this MUST be a shared volume.
  config.derivatives_path = File.join( Rails.root, 'hostfs', 'uploads', 'derivatives' )

  # Location on local file system where uploaded files will be staged
  # prior to being ingested into the repository or having derivatives generated.
  # If you use a multi-server architecture, this MUST be a shared volume.
  config.working_path = File.join( Rails.root, 'hostfs', 'uploads', 'originals' )

  config.ingest_queue_name = :ingest

  # If browse-everything has been configured, load the configs.  Otherwise, set to nil.
  begin
    if defined? BrowseEverything
      config.browse_everything = BrowseEverything.config
    else
      Rails.logger.warn "BrowseEverything is not installed"
    end
  rescue Errno::ENOENT
    config.browse_everything = nil
  end
end

Date::DATE_FORMATS[:standard] = "%m/%d/%Y"

Qa::Authorities::Local.register_subauthority('subjects', 'Qa::Authorities::Local::TableBasedAuthority')
#Qa::Authorities::Local.register_subauthority('languages', 'Qa::Authorities::Local::TableBasedAuthority')
Qa::Authorities::Local.register_subauthority('genres', 'Qa::Authorities::Local::TableBasedAuthority')

