require_env_var() {
  if [[ -z ${!1} ]]
  then
    echo "$1 env var is needed." && exit 1
  fi
}

get_host_from_hostport() {
  echo $(echo $1 | awk -F':' '{ print $1 }')
}

get_port_from_hostport() {
  echo $(echo $1 | awk -F':' '{ print $2 }')
}

# ----------------------------
# Pretty logging & output
# ----------------------------
# Enable colors only when stdout is a TTY, TERM isn't dumb, and NO_COLOR is not set
if [ -t 1 ] && [ "${TERM:-}" != "dumb" ] && [ -z "${NO_COLOR:-}" ]; then
  COLORS_ENABLED=1
else
  COLORS_ENABLED=0
fi

if [ "$COLORS_ENABLED" -eq 1 ]; then
  RESET="\033[0m"; BOLD="\033[1m"; BLUE="\033[34m"; GREEN="\033[32m"; YELLOW="\033[33m"; RED="\033[31m"
else
  RESET=""; BOLD=""; BLUE=""; GREEN=""; YELLOW=""; RED=""
fi

info()    { printf "%b%s%b\n" "$BLUE$BOLD" "==> $1" "$RESET"; }
success() { printf "%b%s%b\n" "$GREEN" "✔ $1" "$RESET"; }
warn()    { printf "%b%s%b\n" "$YELLOW" "! $1" "$RESET"; }
error()   { printf "%b%s%b\n" "$RED" "✖ $1" "$RESET"; }

function _trap_DEBUG() {
    echo "# $BASH_COMMAND";
    while read -r -e -p "debug> " _command; do
        if [ -n "$_command" ]; then
            eval "$_command";
        else
            break;
        fi;
    done
}

# trap '_trap_DEBUG' DEBUG

# ----------------------------
# Solr utility functions
# ----------------------------
curl_post_json() {
  local url="$1"
  local json_payload="$2"
  local can_fail="$3"
  
  if [[ -z "$url" ]]; then
    error "curl_post_json requires: url"
    return 1
  fi
  
  if [[ -z "$json_payload" ]]; then
    error "curl_post_json requires: json_payload"
    return 1
  fi
  
  local curl_output
  curl_output=$(curl ${CURL_OPTS} -X POST -H 'Content-type:application/json' --data-binary "$json_payload" "$url" 2>&1)
  local curl_exit_code=$?
  
  if [[ $curl_exit_code -ne 0 ]]; then
    if [[ "$can_fail" == "can_fail" ]]; then
      warn "allowed failure curl POST for URL: $url (non-fatal)"
      echo "$curl_output"
      return 0
    else
      error "curl POST failed for URL: $url"
      echo "$curl_output"
      return $curl_exit_code
    fi
  fi
  
  echo "$curl_output"
}
delete_solr_field() {
  local field_name="$1"
  
  if [[ -z "$field_name" ]]; then
    error "delete_solr_field requires: field_name"
    return 1
  fi
  
  info "Delete field $field_name"
  curl_post_json "http://${HOST}/solr/${COLLECTION}/schema" "{
    \"delete-field\":
    {
      \"name\": \"$field_name\"
    }
  }" "can_fail"             
}

delete_solr_field_type() {
  local field_type="$1"
  
  if [[ -z "$field_type" ]]; then
    error "delete_solr_field_type requires: field_type"
    return 1
  fi
  
  info "Delete field type $field_type"
  curl_post_json "http://${HOST}/solr/${COLLECTION}/schema" "{
    \"delete-field-type\":
    {
      \"name\": \"$field_type\"
    }
  }" "can_fail" 
}

add_solr_field() {
  local field_name="$1"
  local field_type="$2"
  
  if [[ -z "$field_name" ]]; then
    error "add_solr_field requires: field_name"
    return 1
  fi
  
  if [[ -z "$field_type" ]]; then
    error "add_solr_field requires: field_type"
    return 1 
  fi
  
  # Shift to get optional arguments
  shift 2
  
  # Check for multiValued and notStored arguments (order doesn't matter)
  local multi_valued=""
  local not_stored=""
  
  for arg in "$@"; do
    if [[ "$arg" == "multiValued" ]]; then
      multi_valued="true"
    elif [[ "$arg" == "notStored" ]]; then
      not_stored="true"
    elif [[ "$arg" == "docValues" ]]; then
      doc_values="true"
    fi
  done
  
  # Build the JSON payload
  local json_payload="{
    \"add-field\":
    {
      \"name\": \"$field_name\",
      \"type\": \"$field_type\""
  
  # Add multiValued if present
  if [[ -n "$multi_valued" ]]; then
    json_payload="$json_payload,
      \"multiValued\": true"
  fi
  
  # Add stored:false if notStored is present
  if [[ -n "$not_stored" ]]; then
    json_payload="$json_payload,
      \"stored\": false"
  fi
  
  json_payload="$json_payload
    }
  }"
  
  local log_msg="Add field $field_name (type: $field_type)"
  if [[ -n "$multi_valued" ]]; then
    log_msg="$log_msg, multiValued: true"
  fi
  if [[ -n "$not_stored" ]]; then
    log_msg="$log_msg, stored: false"
  fi
  if [[ -n "$doc_values" ]]; then
    log_msg="$log_msg, docValues: true"
  fi
  
  info "$log_msg"
  local curl_output
  curl_output=$(curl_post_json "http://${HOST}/solr/${COLLECTION}/schema" "$json_payload")
  local curl_exit_code=$?
  
  if [[ $curl_exit_code -ne 0 ]]; then
    error "Failed to add field $field_name"
    return $curl_exit_code
  fi
}
