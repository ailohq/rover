#!/bin/bash

set -eou pipefail

while getopts s:g:u:n:c: flag
do
    case "${flag}" in
        s) schemaName=${OPTARG};;
        g) graphName=${OPTARG};;
        u) url=${OPTARG};;
        n) namespace=${OPTARG};;
        c) check=${OPTARG};;
    esac
done

echo "## ${schemaName^^} ##"
echo ""

rover subgraph introspect "$url" > schema.graphql

if [[ "${check}" == "true" ]]; then
    if rover subgraph fetch atp-ailo-gateway-"$schemaName"-managed@"$namespace" --name "$graphName" &> /dev/null; then
        if ! APOLLO_KEY="${LEGACY_APOLLO_KEY}" rover subgraph check "ailo-gateway-${schemaName}-managed@prod" --name "$graphName" --schema "./schema.graphql"; then
            echo "[Schema Check] Would have failed NORMAL schema check against prod"
        fi

        if ! APOLLO_KEY="${LEGACY_APOLLO_KEY}" rover subgraph check "ailo-gateway-${schemaName}-managed@prod" --name "$graphName" --schema "./schema.graphql" --validation-period="2 days" --query-count-threshold="5"; then
            echo "[Schema Check] Would have failed LENIENT schema check against prod"
        fi

        rover subgraph publish atp-ailo-gateway-"$schemaName"-managed@"$namespace" \
            --name "$graphName" \
            --schema "./schema.graphql" \
            --routing-url "$url" \
            --convert
    else
        # Probably a new namespace
        echo "${graphName} doesn't exist yet"
        
        # Don't log all the unavoidable warnings that appear when publishing a graph for the first time
        rover subgraph publish atp-ailo-gateway-"$schemaName"-managed@"$namespace" \
            --name "$graphName" \
            --schema "./schema.graphql" \
            --routing-url "$url" \
            --convert \
            --log "error"
    fi
fi

EXIT_CODE=$?

echo "exit code: $EXIT_CODE"
echo ""
echo ""
exit $EXIT_CODE

