function get_version {
   local url=$1
   json=$(curl $url/version 2>/dev/null)
   if [ -n "$json" ]; then
      echo $(echo $json|awk -F: '{print $2}'|tr -d "\"}")
      return
   fi
   echo "unknown"
}

function access_service {
   local name=$1
   local url=$2

   if [ -n "$url" ]; then
      version=$(get_version $url)
      echo " $name => $version"
   else
      echo "WARNING $name endpoint not defined; no version info available"
   fi
}

# deposit auth service
access_service "depositauth service" $DEPOSITAUTH_URL

# deposit registration service
access_service "depositreg service" $DEPOSITREG_URL

# entity id service
access_service "entityid service" $ENTITYID_URL

# token authorizer service
access_service "tokenauth service" $TOKENAUTH_URL

# user info service
access_service "userinfo service" $USERINFO_URL

# libra2
access_service "libra2 webapp" $LIBRA2_WEBAPP

# deposit registration
access_service "depositreg webapp" $OPTREG_WEBAPP

exit 0
