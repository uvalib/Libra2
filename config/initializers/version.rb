#
# get the version information from the build tag
#
def get_version
  tag_pattern = "#{Rails.application.root}/buildtag.*"
  files = Dir.glob( tag_pattern )
  if files.length == 1
    return File.basename( files[ 0 ] ).gsub( /buildtag./, '' )
  end
  return( 'unknown' )
end

BUILD_VERSION = get_version( )
