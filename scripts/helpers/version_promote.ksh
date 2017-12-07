#set -x

DIR=$(dirname $0)

# currently configured versions
DEPLOY_FILE=/tmp/deploy.versions
./$DIR/version_deploy.ksh > $DEPLOY_FILE

# versions running on staging
host=docker1
TMP_FILE=/tmp/$host.versions
rm -fr $TMP_FILE > /dev/null 2>&1
DOCKER_HOST=tcp://$host.lib.virginia.edu:2376 ./$DIR/versions.ksh > $TMP_FILE

while read line; do
      if [[ "$line" =~ "Versions" ]]; then
         continue
      fi

      service=$(echo $line | awk -F\| '{print $1}' | awk '{$1=$1};1')
      deployed_tag=$(echo $line | awk -F\| '{print $2}' | awk '{$1=$1};1')

      staging=$(grep "$service" $TMP_FILE)
      if [ -n "$staging" ]; then
         staging_tag=$(echo $staging | awk -F\| '{print $2}' | awk '{$1=$1};1')
         if [ "$staging_tag" != "$deployed_tag" ]; then
            echo "update $service: [$deployed_tag] -> [$staging_tag]"
            UPDATER=$DIR/version_update.ksh
            case $service in
            "depositauth service") components="deposit-auth-ws"
               ;;
            "depositreg service") components="deposit-reg-ws"
               ;;
            "entityid service") components="entity-id-ws"
               ;;
            "ORCID access service") components="orcid-access-ws"
               ;;
            "tokenauth service") components="authtoken-ws"
               ;;
            "userinfo service") components="user-ws"
               ;;
            "libra-etd webapp") components="libra-etd libra-etd-workerpool"
               ;;
            "libra-oc webapp") components="libra-oc libra-oc-workerpool"
               ;;
            "depositreg webapp") components="deposit-registration"
               ;;
            "libra-etd admin webapp") components="libra2-admin"
               ;;
            *) echo "ERROR: unsupported service [$service]; aborting"
               exit 1
               ;;
            esac
            for comp in $components; do
               ./$UPDATER $comp $staging_tag
            done
         fi
      fi

done < $DEPLOY_FILE

#
# end of file
#
