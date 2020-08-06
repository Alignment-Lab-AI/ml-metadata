#!/bin/bash
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Convenience binary to build MLMD from source.

# Put wrapped c++ files in place

# Usage: build_pip_package.sh [--python_bin_path PYTHON_BIN_PATH]

if [[ -z "$1" ]]; then
  PYTHON_BIN_PATH=python
else
  if [[ "$1" == --python_bin_path ]]; then
    shift
    PYTHON_BIN_PATH=$1
  else
    printf "Unrecognized argument $1"
    exit 1
  fi
fi

PLATFORM="$(uname -s | tr 'A-Z' 'a-z')"
function is_windows() {
  if [[ "${PLATFORM}" =~ (cygwin|mingw32|mingw64|msys)_nt* ]]; then
    true
  else
    false
  fi
}

set -u -x

cp -f ${BUILD_WORKSPACE_DIRECTORY}/bazel-bin/ml_metadata/metadata_store/pywrap_tf_metadata_store_serialized.py \
  ${BUILD_WORKSPACE_DIRECTORY}/ml_metadata/metadata_store
cp -f ${BUILD_WORKSPACE_DIRECTORY}/bazel-genfiles/ml_metadata/proto/metadata_store_pb2.py \
  ${BUILD_WORKSPACE_DIRECTORY}/ml_metadata/proto
cp -f ${BUILD_WORKSPACE_DIRECTORY}/bazel-genfiles/ml_metadata/proto/metadata_store_service_pb2.py \
  ${BUILD_WORKSPACE_DIRECTORY}/ml_metadata/proto
cp -f ${BUILD_WORKSPACE_DIRECTORY}/bazel-genfiles/ml_metadata/proto/metadata_store_service_pb2_grpc.py \
  ${BUILD_WORKSPACE_DIRECTORY}/ml_metadata/proto

mkdir -p ${BUILD_WORKSPACE_DIRECTORY}/src
cp -f ${BUILD_WORKSPACE_DIRECTORY}/bazel-bin/ml_metadata \
  ${BUILD_WORKSPACE_DIRECTORY}/src

if is_windows; then
  cp -f ${BUILD_WORKSPACE_DIRECTORY}/bazel-out/x64_windows-opt/genfiles/ml_metadata/metadata_store/_pywrap_tf_metadata_store_serialized.pyd \
    ${BUILD_WORKSPACE_DIRECTORY}/ml_metadata/metadata_store
else
  cp -f ${BUILD_WORKSPACE_DIRECTORY}/bazel-bin/ml_metadata/metadata_store/_pywrap_tf_metadata_store_serialized.so \
    ${BUILD_WORKSPACE_DIRECTORY}/ml_metadata/metadata_store
fi

# Create the wheel
cd ${BUILD_WORKSPACE_DIRECTORY}

${PYTHON_BIN_PATH} setup.py bdist_wheel

# Cleanup
cd -
