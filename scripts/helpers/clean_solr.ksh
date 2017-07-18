if [ -z "$SOLR_URL" ]; then
   echo "ERROR: no SOLR_URL defined"
   exit 1
fi

NAMESPACE=libra2

read -r -p "$SOLR_URL/$NAMESPACE: ARE YOU SURE? [Y/n]? " response
case "$response" in 
  y|Y ) echo "Cleaning $SOLR_URL ..."
  ;;
  * ) exit 1
esac

url="$SOLR_URL/$NAMESPACE/update?stream.body=<delete><query>*:*</query></delete>&commit=true"
curl "$url"

exit 0
