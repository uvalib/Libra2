#!/usr/bin/env bash
. ./env.set
rake libraetd:work:del_all_works
rake libraetd:etd:reset_last_optional_id
rake libraetd:etd:ingest_optional_etd_deposits

