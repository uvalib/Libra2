# temp directory names
ITEM_RECORDS=tmp/extract/4th_year_thesis

# other attributes
DEFAULTS_FILE=data/default_ingest_attributes.yml

# ingest Libra records
bundle exec rake libra2:ingest:legacy_ingest $ITEM_RECORDS $DEFAULTS_FILE

exit 0
