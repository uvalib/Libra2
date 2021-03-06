function get_status {
   local url=$1
   status=$(curl -s -o /dev/null -w "%{http_code}" $url/healthcheck 2>/dev/null)
   if [ "$status" == "200" ]; then
      echo "OK"
      return
   fi
   echo "ERROR"
}

function access_service {
   local name=$1
   local url=$2

   if [ -n "$url" ]; then
      status=$(get_status $url)
      printf "%-25s| %s\n" "$name" "$status"
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
   echo "ERROR: DOCKER_HOST is not defined, aborting"
   exit 1
fi

endpoint=$(echo $DOCKER_HOST | awk -F: '{print $2}'|tr -d "/")
echo "Healthcheck @ $endpoint"

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

# libra-etd
access_service "libra-etd webapp" $(endpoint_url $endpoint 8040)

# libra-oc
access_service "libra-oc webapp" $(endpoint_url $endpoint 8030)

# deposit registration
access_service "depositreg webapp" $(endpoint_url $endpoint 8221)

# libra-etd administration
access_service "libra-etd admin webapp" $(endpoint_url $endpoint 8222)

exit 0
