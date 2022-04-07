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

overallExitCode=0

echo "======================================================================================"
echo "Publishing $schemaName schema from $url"

/root/.rover/bin/rover subgraph introspect "$url" | \
  grep -v -e '^There is a newer version of Rover' -e 'For instructions on how to install' | \
/root/.rover/bin/rover subgraph publish atp-ailo-gateway-"$schemaName"-managed@"$namespace" \
  --name "$graphName" --schema - --routing-url "$url" --convert --output json > /tmp/"$schemaName"-out.json
success=$(cat /tmp/"$schemaName"-out.json | jq '.data.success')
error=$(cat /tmp/"$schemaName"-out.json | jq '.data.error')
supergraphWasUpdated=$(cat /tmp/"$schemaName"-out.json | jq '.data.supergraph_was_updated')
if [[ "$success" != "true" ]]; then
    echo -e "Update of $schemaName failed with: \033[31m$error\033[0m"
    overallExitCode=$((overallExitCode | 1))
else
    echo -e "Update of $schemaName \033[32msucceeded\033[0m, supergraph $([[ $supergraphWasUpdated = 'true' ]] && echo 'was' ||echo 'was NOT ') updated"
fi

echo "======================================================================================"
echo "exit code: $overallExitCode"
exit $overallExitCode
