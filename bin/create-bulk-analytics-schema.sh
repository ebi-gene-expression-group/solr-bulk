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

delete_solr_field "experiment_accession"

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
delete_solr_field "is_private"

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
delete_solr_field "bioentity_identifier"

info "Create field bioentity_identifier (string, DocValues)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "bioentity_identifier",
    "type": "string",
    "docValues": true
  }
}' http://${HOST}/solr/${COLLECTION}/schema

delete_solr_field "bioentity_identifier_search"

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

delete_solr_field "assay_group_id"

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

delete_solr_field "contrast_id"

info "Create field contrast_id (string)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "contrast_id",
    "type": "string"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

delete_solr_field "species"

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

delete_solr_field "kingdom"

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

delete_solr_field "experiment_type"

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
delete_solr_field "default_query_factor_type"

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

delete_solr_field "factors"

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

delete_solr_field "expression_level"

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

delete_solr_field "expression_level_fpkm"

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

delete_solr_field "expression_levels"

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

delete_solr_field expression_levels_fpkm

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

delete_solr_field "num_replicates"

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

delete_solr_field "fold_change"

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

delete_solr_field "p_value"

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

delete_solr_field "t_statistic"

info "Create field t_statistic (pdouble)"
curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":
  {
    "name": "t_statistic",
    "type": "pdouble"
  }
}' http://${HOST}/solr/${COLLECTION}/schema

#############################################################################################

delete_solr_field "regulation"

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

delete_solr_field "identifier_search"

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

delete_solr_field "conditions_search"

delete_solr_field "text_en_tight"

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
