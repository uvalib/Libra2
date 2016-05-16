if [ -z "$SOLR_URL" ]; then
   echo "ERROR: no SOLR_URL defined"
   exit 1
fi

echo "Cleaning $SOLR_URL ..."

for i in development test; do

   url="$SOLR_URL/$i/update?stream.body=<delete><query>*:*</query></delete>&commit=true"
   curl "$url"

done
