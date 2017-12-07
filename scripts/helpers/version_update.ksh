#
# update version configured for production deployment
#

DEPLOY_SCRIPTING_DIR=../build-deploy-scripts

function update_version {
   local dirname=$1
   local tag=$2
   local tagfile=$DEPLOY_SCRIPTING_DIR/$dirname/production.tag

   if [ -f "$tagfile" ]; then
      echo $tag > $tagfile
   else
      echo "ERROR: $tagfile does not exist; version not updated"
   fi
}

if [ $# -ne 2 ]; then
   echo "use: $0 <component name> <tag>"
   exit 1
fi

component_name=$1
tag=$2

if [ ! -d $DEPLOY_SCRIPTING_DIR/$component_name ]; then
   echo "ERROR: component $component_name does not exist; aborting"
   exit 1
fi

update_version "$component_name" "$tag"
exit 0

#
# end of file
#
