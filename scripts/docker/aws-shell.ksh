#if [ -z "$DOCKER_HOST" ]; then
#   echo "ERROR: no DOCKER_HOST defined"
#   exit 1
#fi

if [ -z "$DOCKER_HOST" ]; then
   DOCKER_TOOL=docker
else
   DOCKER_TOOL=docker-17.04.0
fi

#$(aws ecr get-login --no-include-email --region $AWS_DEFAULT_REGION)

# set the definitions
INSTANCE=libra-etd
NAMESPACE=115119339709.dkr.ecr.us-east-1.amazonaws.com/uvalib
TAG=latest

if [ $# -eq 1 ]; then
  TAG=$1
fi

IMAGE=$NAMESPACE/$INSTANCE:$TAG

echo "Using $IMAGE..."
$DOCKER_TOOL run -ti -p 8180:8080 $IMAGE /bin/bash -l
