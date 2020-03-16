#!/usr/bin/env bash
################################################################################
#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

# This script only suit for Flink-1.10 and above.

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`

. "$bin"/config.sh

jvm_params_output=`runBashJavaUtilsCmd GET_TM_RESOURCE_JVM_PARAMS ${FLINK_CONF_DIR}`
jvm_params=`extractExecutionParams "$jvm_params_output"`
if [[ $? -ne 0 ]]; then
    echo "[ERROR] Could not get JVM parameters properly."
    exit 1
fi

echo "JVM Parameters:"
for param in $(echo "$jvm_params" | tr " " "\n")
do
    echo "    $param"
done

echo ""

dynamic_configs_output=`runBashJavaUtilsCmd GET_TM_RESOURCE_DYNAMIC_CONFIGS ${FLINK_CONF_DIR}`
dynamic_configs=`extractExecutionParams "$dynamic_configs_output"`
if [[ $? -ne 0 ]]; then
    echo "[ERROR] Could not get dynamic configurations properly."
    exit 1
fi

dynamic_configs=$(echo $dynamic_configs | sed 's/-D //g')
echo "TaskManager Dynamic Configs:"
for config in $(echo "$dynamic_configs" | tr " " "\n")
do
    echo "    $config"
done
