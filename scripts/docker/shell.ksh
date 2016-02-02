if [ -z "$DOCKER_HOST" ]; then
   echo "ERROR: no DOCKER_HOST defined"
   exit 1
fi

docker run -t -i -p 8140:3000 -e SOLR_URL=http://docker1.lib.virginia.edu:8041/solr/development -e FEDORA_URL=http://docker1.lib.virginia.edu:8041/fedora/rest uvadave/libra2 /bin/bash
