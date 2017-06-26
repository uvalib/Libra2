#
# report versions configured for production deployment
#

DEPLOY_SCRIPTING_DIR=../build-deploy-scripts

function report_version {
   local dirname=$1
   local reportname=$2
   local tagfile=$DEPLOY_SCRIPTING_DIR/$dirname/production.tag

   local tag="unknown"
   if [ -f "$tagfile" ]; then
      tag=$(cat $tagfile)
   fi

   printf "%-25s| %s\n" "$reportname" "$tag"
}

echo "Versions configured for production deployment"

report_version "deposit-auth-ws" "depositauth service"

report_version "deposit-reg-ws" "depositreg service"

report_version "entity-id-ws" "entityid service"

report_version "orcid-access-ws" "ORCID access service"

report_version "authtoken-ws" "tokenauth service"

report_version "user-ws" "userinfo service"

report_version "libra-etd" "libra-etd webapp"
report_version "libra-etd-workerpool" "libra-etd worker pool"

report_version "libra-oc" "libra-oc webapp"
report_version "libra-oc-workerpool" "libra-oc workerpool"

report_version "deposit-registration" "depositreg webapp"

report_version "libra2-admin" "libra-etd admin webapp"

exit 0
