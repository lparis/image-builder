#!/bin/bash
# Copyright 2023 VMware, Inc.
# SPDX-License-Identifier: MPL-2.0

set -e

source $(dirname "${BASH_SOURCE[0]}")/utils.sh
enable_debugging

is_argument_set "KUBERNETES_VERSION argument is required" $KUBERNETES_VERSION


docker_build_args=$(jq -r '."'$KUBERNETES_VERSION'".docker_build_args | keys[]' $SUPPORTED_VERSIONS_JSON)
build_variables=""
for docker_arg in $docker_build_args;
do
    docker_arg_value=$(jq -r '."'$KUBERNETES_VERSION'".docker_build_args."'$docker_arg'"' $SUPPORTED_VERSIONS_JSON)
    build_variables="${build_variables} --build-arg ${docker_arg}=${docker_arg_value}"
done

# by default don't show docker output
docker_debug_flags="-q"
if [ ! -z ${DEBUGGING+x} ]; then
    docker_debug_flags="--progress plain"
fi 

docker build --platform=linux/amd64 $docker_debug_flags \
-t $(get_image_builder_container_image_name $KUBERNETES_VERSION) \
$build_variables $(dirname "${BASH_SOURCE[0]}")/../../.