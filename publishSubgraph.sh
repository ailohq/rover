#!/bin/bash

set -eo pipefail

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

[ -z "$schemaName" ] && die "-s schemaName is not set"
[ -z "$graphName" ] && die "-g graphName is not set"
[ -z "$url" ] && die "-u url is not set"
[ -z "$namespace" ] && die "-n namespace is not set"

echo "Publishing subgraph $graphName to namespace $namespace"

echo "======================================================================================"
echo "Publishing $schemaName schema from $url"

/root/.rover/bin/rover subgraph fetch atp-ailo-gateway-"$schemaName"-managed@"$namespace" \
    --name "$graphName" &> /dev/null \
    && \
    {
        /root/.rover/bin/rover subgraph introspect "$url" \
          | /root/.rover/bin/rover subgraph check atp-ailo-gateway-"$schemaName"-managed@"$namespace" \
            --name "$graphName" \
            --schema - \
          || echo "$graphName doesn't exist yet"
    }

/root/.rover/bin/rover subgraph introspect "$url" \
  | /root/.rover/bin/rover subgraph publish atp-ailo-gateway-"$schemaName"-managed@"$namespace" \
    --name "$graphName" \
    --schema - \
    --routing-url "$url" \
    --convert

EXIT_CODE=$?

echo "======================================================================================"
echo "exit code: $EXIT_CODE"
exit $EXIT_CODE
