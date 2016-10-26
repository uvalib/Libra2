# temp directory names
SOLR_RECORDS=tmp/1
LIBRA_RECORDS=tmp/2
IMPORT_RECORDS=tmp/3

# other attributes
SOLR_QUERY_FILE=data/default_solr_query.txt
MAX_RECORDS=25

# extract records from SOLR
bundle exec rake libra2:extract:solr_extract $SOLR_RECORDS $SOLR_QUERY_FILE $MAX_RECORDS

# process SOLR records and extract Libra records
bundle exec rake libra2:extract:solr_process $SOLR_RECORDS $LIBRA_RECORDS

# process Libra records and extract any assets
bundle exec rake libra2:extract:asset_extract $LIBRA_RECORDS

exit 0
