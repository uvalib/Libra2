# temp directory names
LIBRA_RECORDS=tmp/2

# other attributes
DEFAULTS_FILE=data/default_ingest_attributes.txt

# ingest Libra records
bundle exec rake libra2:ingest:legacy_ingest $LIBRA_RECORDS $DEFAULTS_FILE

exit 0
