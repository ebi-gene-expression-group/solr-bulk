#!/usr/bin/env bash
set -e

# On developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"bulk-analytics"}-v${SCHEMA_VERSION:-"1"}

NUM_SHARDS=${SOLR_NUM_SHARDS:-1}
REPLICATION_FACTOR=${SOLR_REPLICATION_FACTOR:-1}

#############################################################################################

printf "\n\Deleting previous alias of $COLLECTION\n"
curl "http://$HOST/solr/admin/collections?action=DELETEALIAS&name=bulk-analytics"

#############################################################################################

printf "\n\nDeleting collection $COLLECTION based on $HOST\n"
curl "http://$HOST/solr/admin/collections?action=DELETE&name=$COLLECTION"

printf "\n\nCreating collection $COLLECTION based on $HOST\n"
curl "http://$HOST/solr/admin/collections?action=CREATE&name=$COLLECTION&numShards=$NUM_SHARDS&replicationFactor=$REPLICATION_FACTOR"

#############################################################################################

printf "\n\nAliasing base collection atlas-bulk to latest iteration $COLLECTION\n"
curl "http://$HOST/solr/admin/collections?action=CREATEALIAS&name=bulk-analytics&collections=$COLLECTION"

#############################################################################################

printf "\n\nDisabling auto-commit and soft auto-commit in $COLLECTION\n"
curl "http://$HOST/solr/$COLLECTION/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoCommit.maxTime":-1
  }
}'

curl "http://$HOST/solr/$COLLECTION/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoCommit.maxDocs":-1
  }
}'

curl "http://$HOST/solr/$COLLECTION/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoSoftCommit.maxTime":-1
  }
}'

curl "http://$HOST/solr/$COLLECTION/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoSoftCommit.maxDocs":-1
  }
}'
