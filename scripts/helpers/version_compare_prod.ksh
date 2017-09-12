DIR=$(dirname $0)

export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=~/Sandboxes/build-deploy-scripts/certs

for host in dockerprod1 dockerprod2; do
   TMP_FILE=/tmp/$host.versions
   rm -fr $TMP_FILE > /dev/null 2>&1
   DOCKER_HOST=tcp://$host.lib.virginia.edu:2376 ./$DIR/versions.ksh > $TMP_FILE
done

diff /tmp/dockerprod1.versions /tmp/dockerprod2.versions
