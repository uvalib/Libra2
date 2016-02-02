if [ -z "$DOCKER_HOST" ]; then
   echo "ERROR: no DOCKER_HOST defined"
   exit 1
fi

# set the definitions
INSTANCE=libra2
NAMESPACE=uvadave

# stop the running instance
docker stop $INSTANCE

# remove the instance
docker rm $INSTANCE

# remove the previously tagged version
docker rmi $NAMESPACE/$INSTANCE:current  

# tag the latest as the current
docker tag -f $NAMESPACE/$INSTANCE:latest $NAMESPACE/$INSTANCE:current

# run it
docker run -d -p 8040:3000 -e SOLR_URL=http://docker1.lib.virginia.edu:8041/solr/development -e FEDORA_URL=http://docker1.lib.virginia.edu:8041/fedora/rest --name $INSTANCE $NAMESPACE/$INSTANCE:latest
