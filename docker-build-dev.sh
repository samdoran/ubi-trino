#!/bin/bash -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PRESTO_VER=$(${SCRIPT_DIR}/get_presto_version.sh)

echo "Executing local presto docker image build..."
docker build \
       -t quay.io/cloudservices/ubi-presto:latest \
       -t quay.io/cloudservices/ubi-presto:${PRESTO_VER} \
       -f "${SCRIPT_DIR}/Dockerfile" \
       $@ \
       "${SCRIPT_DIR}"

