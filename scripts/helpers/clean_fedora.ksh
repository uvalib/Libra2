if [ -z "$FEDORA_URL" ]; then
   echo "ERROR: no FEDORA_URL defined"
   exit 1
fi

if [ -z "$FEDORA_CREDS" ]; then
   echo "ERROR: no FEDORA_CREDS defined"
   exit 1
fi

echo "Cleaning $FEDORA_URL ..."

for i in dev test; do

   url=$FEDORA_URL/$i
   curl --user $FEDORA_CREDS -X DELETE $url
   curl --user $FEDORA_CREDS -X DELETE $url/fcr:tombstone

done
