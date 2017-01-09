function get_runtime {
   local url=$1
   json=$(curl $url/runtime 2>/dev/null)
   if [ -n "$json" ]; then
      echo $(echo $json|tr -d "\"{}"|tr "," " "|tr ":" "=")
      return
   fi
   echo "unknown"
}

function access_service {
   local name=$1
   local url=$2

   if [ -n "$url" ]; then
      runtime=$(get_runtime $url)
      echo " $name => $runtime"
   else
      echo "WARNING $name endpoint not defined; no runtime info available"
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

# ORCID access service
access_service "ORCID access service" $(endpoint_url $endpoint 8250)

# token authorizer service
access_service "tokenauth service" $(endpoint_url $endpoint 8200)

# user info service
access_service "userinfo service" $(endpoint_url $endpoint 8240)

exit 0
