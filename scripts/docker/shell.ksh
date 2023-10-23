#if [ -z "$DOCKER_HOST" ]; then
#   echo "ERROR: no DOCKER_HOST defined"
#   exit 1
#fi

if [ -z "$DOCKER_HOST" ]; then
   DOCKER_TOOL=docker
else
   DOCKER_TOOL=docker-legacy
fi

# environment attributes
DOCKER_ENV=""

$DOCKER_TOOL run -t -i -p 8140:3000 $DOCKER_ENV uvadave/libra-etd /bin/bash -l
