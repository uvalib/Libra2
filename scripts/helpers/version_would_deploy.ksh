DIR=$(dirname $0)

DEPLOY_FILE=/tmp/deploy.versions
./$DIR/version_deploy.ksh > $DEPLOY_FILE

for host in dockerprod1 dockerprod2; do
   TMP_FILE=/tmp/$host.versions
   rm -fr $TMP_FILE > /dev/null 2>&1
   DOCKER_HOST=tcp://$host.lib.virginia.edu:2376
   ./$DIR/versions.ksh > $TMP_FILE
done

for host in dockerprod1 dockerprod2; do
   TMP_FILE=/tmp/$host.versions
   echo "$host:"
   while read line; do
      if [[ "$line" =~ "Versions" ]]; then
         continue
      fi

      service=$(echo $line | awk -F\| '{print $1}')
      tag=$(echo $line | awk -F\| '{print $2}')

      current=$(grep "$service" $TMP_FILE)
      if [ -n "$current" ]; then
         new_tag=$(echo $current | awk -F\| '{print $2}')
         if [ "$new_tag" != "$tag" ]; then
            printf "%-25s %s => %s\n" "$service" "$tag" "$new_tag"
         fi
      fi

   done < $DEPLOY_FILE
done
