#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

DOCKER_COMPOSE_FILE=docker-compose.yml

trap "exit_status=\$?; docker-compose -f $DOCKER_COMPOSE_FILE stop && docker-compose -f $DOCKER_COMPOSE_FILE rm --force && exit \$exit_status" EXIT

echo "--- docker-compose run build"
docker-compose -f $DOCKER_COMPOSE_FILE run build

IMAGE=ailohq/${SERVICE_NAME}:${TAG}
IMAGE_AWS="${AILO_AWS_ECR_URI}/ailo/${SERVICE_NAME}:${TAG}"
IMAGE_AWS_LATEST="${AILO_AWS_ECR_URI}/ailo/${SERVICE_NAME}:latest"

echo "--- docker build"
docker build -t "${IMAGE}" -t "${IMAGE_AWS}" --build-arg TAG="${TAG}" .

echo "--- docker login"
docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"

echo "--- docker push ${IMAGE} to dockerhub"
docker push "${IMAGE}"

echo "--- docker login AWS"
aws ecr create-repository --repository-name "ailo/${SERVICE_NAME}" || true
aws ecr set-repository-policy --repository-name "ailo/${SERVICE_NAME}" --policy-text "${AILO_AWS_ECR_POLICY}"
aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin "${AILO_AWS_ECR_URI}"

echo "--- docker push ${IMAGE_AWS}}"
docker push "${IMAGE_AWS}"
docker push "${IMAGE_AWS_LATEST}"
