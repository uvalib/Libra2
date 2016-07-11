#!/usr/bin/env bash
. ./env.set
rake libra2:work:del_all_works
rake libra2:etd:reset_last_optional_id
rake libra2:etd:ingest_optional_etd_deposits

