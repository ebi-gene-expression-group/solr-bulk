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

#############################################################################################

info "Delete field experiment_accession"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "experiment_accession"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field experiment_accession (string, DocValues)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "experiment_accession",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete field is_private"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "is_private"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field is_private (boolean)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "is_private",
    "type": "boolean"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete copy field rule bioentity_identifier -> bioentity_identifier_search"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-copy-field":
  {
    "source": "bioentity_identifier",
    "dest": "bioentity_identifier_search"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Delete field bioentity_identifier"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "bioentity_identifier"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field bioentity_identifier (string, DocValues)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "bioentity_identifier",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Delete field bioentity_identifier_search"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "bioentity_identifier_search"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field bioentity_identifier_search (lowercase)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "bioentity_identifier_search",
    "type": "lowercase"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Add copy field rule bioentity_identifier -> bioentity_identifier_search"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":
  {
    "source": "bioentity_identifier",
    "dest": "bioentity_identifier_search"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete field assay_group_id"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field" :
  {
    "name": "assay_group_id"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field assay_group_id (string, DocValues)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "assay_group_id",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete field contrast_id"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "contrast_id"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field contrast_id (string)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "contrast_id",
    "type": "string"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete field species"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "species"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field species (string, DocValues)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "species",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete field kingdom"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "kingdom"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field kingdom (string, DocValues)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "kingdom",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema


#############################################################################################

info "Delete field experiment_type"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "experiment_type"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field experiment_type (string, DocValues)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "experiment_type",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete field default_query_factor_type"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "default_query_factor_type"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field default_query_factor_type (string, DocValues)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "default_query_factor_type",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema


#############################################################################################

info "Delete field factors"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "factors"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field factors (string, multi-valued, DocValues)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "factors",
    "type": "string",
    "multiValued": true,
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete field expression_level"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "expression_level"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field expression_level (pdouble, DocValues)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "expression_level",
    "type": "pdouble",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete field expression_level_fpkm"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "expression_level_fpkm"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field expression_level_fpkm (pdouble, DocValues)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "expression_level_fpkm",
    "type": "pdouble",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete expression_levels"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "expression_levels"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create expression_levels (pdouble, multi-valued)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "expression_levels",
    "type": "pdouble",
    "multiValued": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete expression_levels_fpkm"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "expression_levels_fpkm"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create expression_levels_fpkm (pdouble, multi-valued)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "expression_levels_fpkm",
    "type": "pdouble",
    "multiValued": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete field num_replicates"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "num_replicates"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field num_replicates (pint, DocValues)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "num_replicates",
    "type": "pint",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete field fold_change"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "fold_change"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field fold_change (pdouble, DocValues)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "fold_change",
    "type": "pdouble",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete field p_value"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "p_value"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field p_value (pdouble, DocValues)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "p_value",
    "type": "pdouble",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete field t_statistic"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "t_statistic"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field t_statistic (pdouble)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "t_statistic",
    "type": "pdouble"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete field regulation"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field":
  {
    "name": "regulation"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field regulation (string, DocValues)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "regulation",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete dynamic field rule keyword_*"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-dynamic-field": {
     "name": "keyword_*"}
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create dynamic rule keyword_* (string, multi-valued)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field": {
     "name": "keyword_*",
     "type": "lowercase",
     "multiValued": true}
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete field identifier_search"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field" :
  {
    "name": "identifier_search"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Create field identifier_search (text_en)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "identifier_search",
    "type": "text_en",
    "stored": false
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete field conditions_search"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field" :
  {
    "name": "conditions_search"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

info "Delete field type text_en_tight"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-field-type":
  {
    "name": "text_en_tight"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

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

info "Create field conditions_search (text_en_tight)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "conditions_search",
    "type": "text_en_tight",
    "stored": false
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

info "Delete dedupe update processor"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "delete-updateprocessor": "dedupe"
}' http://${HOST}/solr/${COLLECTION}/config


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
