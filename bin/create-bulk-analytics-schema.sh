#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. ${DIR}/schema-version.env
. ${DIR}/common_routines.sh
# Exit on error and fail pipelines if any command fails
set -e
set -o pipefail
# On developers environment export SOLR_HOST and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
SOLR_USER=${SOLR_USER:-"solr"}
SOLR_PASS=${SOLR_PASS:-"SolrRocks"}
SOLR_AUTH="-u ${SOLR_USER}:${SOLR_PASS}"
COLLECTION=${SOLR_COLLECTION:-"bulk-analytics-v${SCHEMA_VERSION}"}
DEBUG_POPULATION=${DEBUG_POPULATION:-"false"}
CURL_OPTS="${SOLR_AUTH} --fail"
if [ "${DEBUG_POPULATION}" = "true" ]; then
  set -vx
  CURL_OPTS="${CURL_OPTS} -v"
fi

delete_solr_field "experiment_accession"
add_solr_field "experiment_accession" "string" docValues

info "Delete field is_private"
delete_solr_field "is_private"
add_solr_field "is_private" "boolean"

info "Delete copy field rule bioentity_identifier -> bioentity_identifier_search"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-copy-field":
  {
    "source": "bioentity_identifier",
    "dest": "bioentity_identifier_search"
  }
}' http://${HOST}/solr/${COLLECTION}/schema || warn "field delete may have been unnecessary"
delete_solr_field "bioentity_identifier"
add_solr_field "bioentity_identifier" "string" docValues
delete_solr_field "bioentity_identifier_search"
add_solr_field "bioentity_identifier_search" "lowercase"
info "Add copy field rule bioentity_identifier -> bioentity_identifier_search"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":
  {
    "source": "bioentity_identifier",
    "dest": "bioentity_identifier_search"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

delete_solr_field "assay_group_id"
add_solr_field "assay_group_id" "string" docValues

delete_solr_field "contrast_id"
add_solr_field "contrast_id" "string"

delete_solr_field "species"
add_solr_field "species" "string" docValues

delete_solr_field "kingdom"
add_solr_field "kingdom" "string" docValues

delete_solr_field "experiment_type"
add_solr_field "experiment_type" "string" docValues

delete_solr_field "default_query_factor_type"
add_solr_field "default_query_factor_type" "string" docValues

delete_solr_field "factors"
add_solr_field "factors" "string" multiValued docValues

delete_solr_field "expression_level"
add_solr_field "expression_level" "pdouble" docValues

delete_solr_field "expression_level_fpkm"
add_solr_field "expression_level_fpkm" "pdouble" docValues

delete_solr_field "expression_levels"
add_solr_field "expression_levels" "pdouble" multiValued

delete_solr_field expression_levels_fpkm
add_solr_field "expression_levels_fpkm" "pdouble" multiValued

delete_solr_field "num_replicates"
add_solr_field "num_replicates" "pint" docValues

delete_solr_field "fold_change"
add_solr_field "fold_change" "pdouble" docValues

delete_solr_field "p_value"
add_solr_field "p_value" "pdouble" docValues

delete_solr_field "t_statistic"
add_solr_field "t_statistic" "pdouble"

delete_solr_field "regulation"
    add_solr_field "regulation" "string" docValues

info "Delete dynamic field rule keyword_*"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field": {
     "name": "keyword_*"}
}' http://${HOST}/solr/${COLLECTION}/schema || warn "field delete may have been unnecessary"

info "Create dynamic rule keyword_* (string, multi-valued)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field": {
     "name": "keyword_*",
     "type": "lowercase",
     "multiValued": true}
}' http://${HOST}/solr/${COLLECTION}/schema

delete_solr_field "identifier_search"
add_solr_field "identifier_search" "text_en" notStored

delete_solr_field "conditions_search"
info "Delete field type text_en_tight"

delete_solr_field_type "text_en_tight"

info "Create field type text_en_tight"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field-type": {
    "name": "text_en_tight",
    "class": "solr.TextField",
    "positionIncrementGap": "100",
    "analyzer" : {
      "tokenizer": {
        "class": "solr.WhitespaceTokenizerFactory"
      },
      "filters": [
        {
          "class":"solr.LowerCaseFilterFactory"
        },
        {
          "class":"solr.EnglishPossessiveFilterFactory"
        },
        {
          "class":"solr.PorterStemFilterFactory"
        }
      ]
    }
  }
}' http://${HOST}/solr/${COLLECTION}/schema
add_solr_field "conditions_search" "text_en_tight" notStored

info "Delete dedupe update processor"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-updateprocessor": "dedupe"
}' http://${HOST}/solr/${COLLECTION}/config || warn "update processor delete may have been unnecessary"

info "Disable autoCreateFields (aka “Data driven schema”)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "set-user-property": {
    "update.autoCreateFields": "false"
  }
}' http://${HOST}/solr/${COLLECTION}/config

info "Create dedupe update processor"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-updateprocessor":
  {
    "name": "dedupe"
    "class": "solr.processor.SignatureUpdateProcessorFactory",
    "enabled": "true",
    "signatureField": "id",
    "overwriteDupes": "true",
    "fields": "experiment_accession,bioentity_identifier,assay_group_id,contrast_id",
    "signatureClass": "solr.processor.Lookup3Signature"
  }
}' http://${HOST}/solr/${COLLECTION}/config
