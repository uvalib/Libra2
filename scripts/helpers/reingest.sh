#!/usr/bin/env bash
. ./env.set
rake libraetd:work:del_all_works
rake libraetd:optionaletd:reset_last_optional_id
rake libraetd:optionaletd:ingest_optional_etd_deposits

