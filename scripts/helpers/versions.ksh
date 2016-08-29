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

function endpoint_url {
   local host=$1
   local port=$2
   echo "http://$host:$port"
}

if [ -z "$DOCKER_HOST" ]; then
   echo "ERROR $DOCKER_HOST is not defined, aborting"
   exit 1
fi

endpoint=$(echo $DOCKER_HOST | awk -F: '{print $1}')
echo "Versions @ $endpoint"

# deposit auth service
access_service "depositauth service" $(endpoint_url $endpoint 8230)

# deposit registration service
access_service "depositreg service" $(endpoint_url $endpoint 8220)

# entity id service
access_service "entityid service" $(endpoint_url $endpoint 8210)

# token authorizer service
access_service "tokenauth service" $(endpoint_url $endpoint 8200)

# user info service
access_service "userinfo service" $(endpoint_url $endpoint 8240)

# libra2
access_service "libra2 webapp" $(endpoint_url $endpoint 8040)

# deposit registration
access_service "depositreg webapp" $(endpoint_url $endpoint 8221)

# libra2 administration
access_service "libra2 admin webapp" $(endpoint_url $endpoint 8222)

exit 0
