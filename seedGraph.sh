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
        n) namespace=${OPTARG};;
        *) usage;;
    esac
done

[ -z "$schemaName" ] && die "-s schemaName is not set"
[ -z "$namespace" ] && die "-n namespace is not set"

echo "Initialising graph $schema for namespace $namespace"

echo "======================================================================================"
echo "Publishing $schemaName schema from atp-ailo-gateway-${schema}-managed@dev"

/root/.rover/bin/rover supergraph fetch atp-ailo-gateway-${schema}-managed@"$namespace" \
    && echo "Graph: atp-ailo-gateway-${schema}-managed@$namespace already exists!" \
    || /root/.rover/bin/rover supergraph fetch atp-ailo-gateway-${schema}-managed@dev \
        | /root/.rover/bin/rover graph publish atp-ailo-gateway-${schema}-managed@"$namespace" --schema -

EXIT_CODE=$?

echo "======================================================================================"
echo "exit code: $EXIT_CODE"
exit $EXIT_CODE
