if [ -z "$DOCKER_HOST" ]; then
   echo "ERROR: no DOCKER_HOST defined"
   exit 1
fi

# environment attributes
SOLR_URL=http://docker1.lib.virginia.edu:8041/solr/development
FEDORA_URL=http://docker1.lib.virginia.edu:8041/fedora/rest
REDIS_HOST=docker2.lib.virginia.edu
ENTITYID_URL=http://docker1.lib.virginia.edu:8210/entityid
API_TOKEN=94DE1D63-72F1-44A1-BC7D-F12FC951

DOCKER_ENV="-e SOLR_URL=$SOLR_URL -e FEDORA_URL=$FEDORA_URL -e REDIS_HOST=$REDIS_HOST -e ENTITYID_URL=$ENTITYID_URL -e API_TOKEN=$API_TOKEN"

docker run -t -i -p 8140:3000 $DOCKER_ENV uvadave/libra2 /bin/bash
