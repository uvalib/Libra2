# temp directory names
ASSET_RECORDS=tmp/file_assets
ITEM_RECORDS=tmp/1

# other attributes
MAX_RECORDS=9999



function bomb_if_error {
   local res=$1
   if [ $res -ne 0 ]; then
      echo "ERROR $res, aborting"
      exit $res
   fi
}

# extract file assets thesis from SOLR
echo ""
echo "Extracting all file asset records..."
echo ""
#bundle exec rake libra2:extract:solr_extract $ASSET_RECORDS data/solr_query/file_asset_solr_query.txt $MAX_RECORDS
res=$?
bomb_if_error $res

# extract 4th year thesis from SOLR
echo ""
echo "Extracting all document records..."
echo ""
#bundle exec rake libra2:extract:solr_extract $ITEM_RECORDS data/solr_query/4th_year_thesis_solr_query.txt $MAX_RECORDS
#bundle exec rake libra2:extract:solr_extract $ITEM_RECORDS data/solr_query/master_thesis_solr_query.txt $MAX_RECORDS
#bundle exec rake libra2:extract:solr_extract $ITEM_RECORDS data/solr_query/doctoral_thesis_solr_query.txt $MAX_RECORDS
#bundle exec rake libra2:extract:solr_extract $ITEM_RECORDS data/solr_query/jefferson_trust_solr_query.txt $MAX_RECORDS
res=$?
bomb_if_error $res

# process Libra records and extract any assets
echo ""
echo "Downloading document assets..."
echo ""
#bundle exec rake libra2:extract:asset_extract $ITEM_RECORDS $ASSET_RECORDS
res=$?
bomb_if_error $res

exit 0
