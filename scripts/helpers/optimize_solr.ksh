if [ -z "$SOLR_URL" ]; then
   echo "ERROR: no SOLR_URL defined"
   exit 1
fi

NAMESPACE=libra2

read -r -p "$SOLR_URL/$NAMESPACE: ARE YOU SURE? [Y/n]? " response
case "$response" in 
  y|Y ) echo "Optimizing $SOLR_URL ..."
  ;;
  * ) exit 1
esac

url="$SOLR_URL/$NAMESPACE/update?optimize=true"
curl "$url"

exit 0
