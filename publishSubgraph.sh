#!/bin/bash

set -ou pipefail

function die() {
  echo $1
  exit 1
}

while getopts s:g:u:n: flag
do
    case "${flag}" in
        s) schemaName=${OPTARG};;
        g) graphName=${OPTARG};;
        u) url=${OPTARG};;
        n) namespace=${OPTARG};;
        *) usage;;
    esac
done
echo "Publishing subgraph ${graphName} for namespace ${namespace}"

if /root/.rover/bin/rover subgraph fetch atp-ailo-gateway-"$schemaName"-managed@"$namespace" --name "$graphName" &> /dev/null; then
    if ! /root/.rover/bin/rover subgraph introspect "$url" | /root/.rover/bin/rover subgraph check atp-ailo-gateway-"$schemaName"-managed@"$namespace" --name "$graphName" --schema -; then
        echo "Schema checks failed"
        exit 1
    fi

else
    echo "${graphName} doesn't exist yet"
fi

/root/.rover/bin/rover subgraph introspect "$url" \
  | /root/.rover/bin/rover subgraph publish atp-ailo-gateway-"$schemaName"-managed@"$namespace" \
    --name "$graphName" \
    --schema - \
    --routing-url "$url" \
    --convert

EXIT_CODE=$?

echo "exit code: $EXIT_CODE"
exit $EXIT_CODE
