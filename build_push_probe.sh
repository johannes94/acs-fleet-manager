#!/bin/bash -e
#
# Copyright (c) 2018 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This script builds and deploys the Probe services. In order to
# work, it needs the following variables defined in the CI/CD configuration of
# the project:
#
# QUAY_PROBE_USER - The name of the robot account used to push images to
# 'quay.io', for example 'openshift-unified-hybrid-cloud+jenkins'.
#
# QUAY_PROBE_TOKEN - The token of the robot account used to push images to
# 'quay.io'.
#
# The machines that run this script need to have access to internet, so that
# the built images can be pushed to quay.io.

# The version should be a 7-char hash from git. This is what the deployment process in app-interface expects.
VERSION=$(git rev-parse --short=7 HEAD)

# Set image repository to default value if it is not passed via env
PROBE_IMAGE_REPOSITORY="${QUAY_PROBE_IMAGE_REPOSITORY:-rhacs-eng/blackbox-monitoring-probe-service}"

# Set the directory for docker configuration:
DOCKER_CONFIG="${PWD}/.docker"

# Log in to the image registry:
if [ -z "${QUAY_PROBE_USER}" ]; then
  echo "The probe service quay.io push user name hasn't been provided."
  echo "Make sure to set the QUAY_PROBE_USER environment variable."
  exit 1
fi
if [ -z "${QUAY_PROBE_TOKEN}" ]; then
  echo "The probe service quay.io push token hasn't been provided."
  echo "Make sure to set the QUAY_PROBE_TOKEN environment variable."
  exit 1
fi

# Set up the docker config directory
mkdir -p "${DOCKER_CONFIG}"

# Push the image:
echo "Quay.io user and token are set, will push images to $PROBE_IMAGE_REPOSITORY."
make \
  DOCKER_CONFIG="${DOCKER_CONFIG}" \
  QUAY_PROBE_USER="${QUAY_PROBE_USER}" \
  QUAY_PROBE_TOKEN="${QUAY_PROBE_TOKEN}" \
  TAG="${VERSION}" \
  external_image_registry="quay.io" \
  internal_image_registry="quay.io" \
  probe_image_repository="${PROBE_IMAGE_REPOSITORY}" \
  docker/login/probe \
  image/push/probe

make \
  DOCKER_CONFIG="${DOCKER_CONFIG}" \
  QUAY_PROBE_USER="${QUAY_PROBE_USER}" \
  QUAY_PROBE_TOKEN="${QUAY_PROBE_TOKEN}" \
  TAG="main" \
  external_image_registry="quay.io" \
  internal_image_registry="quay.io" \
  probe_image_repository="${PROBE_IMAGE_REPOSITORY}" \
  docker/login/probe \
  image/push/probe
