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

echo "Initialising graph $schemaName for namespace $namespace"

echo "======================================================================================"
echo "Publishing $schemaName schema from atp-ailo-gateway-$schemaName-managed@dev"

BASE_SCHEMA="schema {
  query: Query
  mutation: Mutation
}

type Mutation @extends {
  atpEmptyStarterSchemaNoop: Boolean
}

type Query @extends {
  atpEmptyStarterSchemaNoop: Boolean
}
"

/root/.rover/bin/rover supergraph fetch atp-ailo-gateway-$schemaName-managed@$namespace &> /dev/null \
    && echo "Graph: atp-ailo-gateway-$schemaName-managed@$namespace already exists!" \
    || echo $BASE_SCHEMA | /root/.rover/bin/rover subgraph publish atp-ailo-gateway-$schemaName-managed@$namespace --schema - --convert --name atp-empty-starter-schema --routing-url ""

EXIT_CODE=$?

echo "======================================================================================"
echo "exit code: $EXIT_CODE"
exit $EXIT_CODE
