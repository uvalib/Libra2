# temp directory names
ITEM_RECORDS=tmp/1

# other attributes
DEFAULTS_FILE=data/default_ingest_attributes.txt

# ingest Libra records
bundle exec rake libra2:ingest:legacy_ingest $ITEM_RECORDS $DEFAULTS_FILE

exit 0
