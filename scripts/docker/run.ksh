if [ -z "$DOCKER_HOST" ]; then
   echo "ERROR: no DOCKER_HOST defined"
   exit 1
fi

# set the definitions
INSTANCE=libra2
NAMESPACE=uvadave

# environment attributes
SOLR_URL=http://docker1.lib.virginia.edu:8041/solr/development
FEDORA_URL=http://docker1.lib.virginia.edu:8041/fedora/rest
REDIS_HOST=docker2.lib.virginia.edu
ENTITYID_URL=http://docker1.lib.virginia.edu:8210/entityid
API_TOKEN=94DE1D63-72F1-44A1-BC7D-F12FC951

DOCKER_ENV="-e SOLR_URL=$SOLR_URL -e FEDORA_URL=$FEDORA_URL -e REDIS_HOST=$REDIS_HOST -e ENTITYID_URL=$ENTITYID_URL -e API_TOKEN=$API_TOKEN"

# stop the running instance
docker stop $INSTANCE

# remove the instance
docker rm $INSTANCE

# remove the previously tagged version
docker rmi $NAMESPACE/$INSTANCE:current  

# tag the latest as the current
docker tag -f $NAMESPACE/$INSTANCE:latest $NAMESPACE/$INSTANCE:current

# run it
docker run -d -p 8040:3000 $DOCKER_ENV --name $INSTANCE $NAMESPACE/$INSTANCE:latest
