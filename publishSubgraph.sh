#!/bin/bash

set -ou pipefail

function die() {
  echo $1
  exit 1
}

while getopts s:g:u:n:c: flag
do
    case "${flag}" in
        s) schemaName=${OPTARG};;
        g) graphName=${OPTARG};;
        u) url=${OPTARG};;
        n) namespace=${OPTARG};;
        c) check=${OPTARG};;
        *) usage;;
    esac
done

echo "## ${schemaName^^} ##"
echo ""

if [[ "${check}" == "true" ]]; then
    if /root/.rover/bin/rover subgraph fetch atp-ailo-gateway-"$schemaName"-managed@"$namespace" --name "$graphName" &> /dev/null; then
        if ! /root/.rover/bin/rover subgraph introspect "$url" | /root/.rover/bin/rover subgraph check "ailo-gateway-${schemaName}-managed@prod" --name "$graphName" --schema -; then
            echo "[Schema Check] Would have failed NORMAL schema check against prod"
        fi

        if ! /root/.rover/bin/rover subgraph introspect "$url" | /root/.rover/bin/rover subgraph check "ailo-gateway-${schemaName}-managed@prod" --name "$graphName" --schema - --validation-period="2 days" --query-count-threshold="5"; then
            echo "[Schema Check] Would have failed LENIENT schema check against prod"
        fi
    else
        echo "${graphName} doesn't exist yet"
    fi
fi

/root/.rover/bin/rover subgraph introspect "$url" \
  | /root/.rover/bin/rover subgraph publish atp-ailo-gateway-"$schemaName"-managed@"$namespace" \
    --name "$graphName" \
    --schema - \
    --routing-url "$url" \
    --convert

EXIT_CODE=$?

echo "exit code: $EXIT_CODE"
echo ""
echo ""
exit $EXIT_CODE
