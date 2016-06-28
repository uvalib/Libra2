if [ -z "$FEDORA_URL" ]; then
   echo "ERROR: no FEDORA_URL defined"
   exit 1
fi

if [ -z "$FEDORA_USER" ]; then
   echo "ERROR: no FEDORA_USER defined"
   exit 1
fi

if [ -z "$FEDORA_PASSWD" ]; then
   echo "ERROR: no FEDORA_PASSWD defined"
   exit 1
fi

echo "Cleaning $FEDORA_URL ..."

for i in dev test prod libra2/dev libra2/test libra2/prod; do

   url=$FEDORA_URL/$i
   echo -n "$url ..."
   curl -o /dev/null -w "%{http_code}\n" --user $FEDORA_USER:$FEDORA_PASSWD -X DELETE $url 2>/dev/null
   res=$?
   if [ $res -ne 0 ]; then
      echo "ERROR: returns $res"
   fi
   echo -n "$url ..."
   curl -o /dev/null -w "%{http_code}\n" --user $FEDORA_USER:$FEDORA_PASSWD -X DELETE $url/fcr:tombstone 2>/dev/null
   res=$?
   if [ $res -ne 0 ]; then
      echo "ERROR: returns $res"
   fi

done
