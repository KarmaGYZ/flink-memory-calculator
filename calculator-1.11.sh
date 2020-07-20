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

# This script only suit for Flink-1.10.
# Usage: calculator.sh [-h] [-D args]
#        -h human readable mode

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`

. "$bin"/config.sh

if [ "$1" == "-h" ]; then
    HUMAN_READABLE="human"
    shift
    echo "There may be precision loss in human readable mode."
fi

ARGS="${@:1}"

translate_to_human_readable() {
    origin_param=$1
    if [ $(echo $origin_param | grep -c 'taskmanager.cpu.cores') != "0" ]; then
        echo $origin_param
    else
        size=$(echo $origin_param |grep -o '[0-9]\+')
        if (( size < 1024 )); then
            echo $origin_param | sed 's/b$//g' | sed 's/$/b/g'
        elif (( size < 1048576 )); then
            size_in_kb=$(( $size / 1024 ))
            echo $origin_param | sed "s/$size/$size_in_kb/g" | sed 's/b$//g' | sed 's/$/kb/g'
        elif (( size < 1073741824 )); then
            size_in_mb=$(( $size / 1048576 ))
            echo $origin_param | sed "s/$size/$size_in_mb/g" | sed 's/b$//g' | sed 's/$/mb/g'
        else
            size_in_gb=$(( $size / 1073741824 ))
            echo $origin_param | sed "s/$size/$size_in_gb/g" | sed 's/b$//g' | sed 's/$/g/g'
        fi
    fi
}

java_utils_output=$(runBashJavaUtilsCmd GET_TM_RESOURCE_PARAMS "${FLINK_CONF_DIR}" "$FLINK_BIN_DIR/bash-java-utils.jar:$(findFlinkDistJar)" "${ARGS[@]}")
logging_output=$(extractLoggingOutputs "${java_utils_output}")
params_output=$(extractExecutionResults "${java_utils_output}" 2)

if [[ $? -ne 0 ]]; then
    echo "[ERROR] Could not get JVM parameters and dynamic configurations properly."
    echo "[ERROR] Raw output from BashJavaUtils:"
    echo "$java_utils_output"
    exit 1
fi

jvm_params=$(echo "${params_output}" | head -n 1)
IFS=$" " dynamic_configs=$(echo "${params_output}" | tail -n 1)

echo "JVM Parameters:"
for param in $(echo "$jvm_params")
do
    if [ -z $HUMAN_READABLE ]; then
        echo "    $param"
    else
        human_readable_param=$(translate_to_human_readable $param)
        echo "    $human_readable_param"
    fi
done

echo ""

dynamic_configs=$(echo $dynamic_configs | sed 's/-D //g')
echo "TaskManager Dynamic Configs:"
for config in $(echo "$dynamic_configs")
do
    if [ -z $HUMAN_READABLE ]; then
        echo "    $config"
    else
        human_readable_config=$(translate_to_human_readable $config)
        echo "    $human_readable_config"
    fi
done

