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

runBashJavaUtilsCmd() {
    local cmd=$1
    local conf_dir=$2
    local class_path="${3:-$FLINK_BIN_DIR/bash-java-utils.jar:`findFlinkDistJar`}"
    class_path=`manglePathList ${class_path}`
    local args="$4"

    local output=`${JAVA_RUN} -classpath ${class_path} org.apache.flink.runtime.util.BashJavaUtils ${cmd} --configDir ${conf_dir} $args 2>&1 | tail -n 1000`
    if [[ $? -ne 0 ]]; then
        echo "[ERROR] Cannot run BashJavaUtils to execute command ${cmd}." 1>&2
        # Print the output in case the user redirect the log to console.
        echo "$output" 1>&2
        exit 1
    fi

    echo "$output"
}

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

jvm_params_output=$(runBashJavaUtilsCmd GET_TM_RESOURCE_JVM_PARAMS ${FLINK_CONF_DIR} $FLINK_BIN_DIR/bash-java-utils.jar:$(findFlinkDistJar) "$ARGS")
jvm_params=`extractExecutionParams "$jvm_params_output"`
if [[ $? -ne 0 ]]; then
    echo "[ERROR] Could not get JVM parameters properly."
    exit 1
fi

echo "JVM Parameters:"
for param in $(echo "$jvm_params" | tr " " "\n")
do
    if [ -z $HUMAN_READABLE ]; then
        echo "    $param"
    else
        human_readable_param=$(translate_to_human_readable $param)
        echo "    $human_readable_param"
    fi
done

echo ""

dynamic_configs_output=$(runBashJavaUtilsCmd GET_TM_RESOURCE_DYNAMIC_CONFIGS ${FLINK_CONF_DIR} $FLINK_BIN_DIR/bash-java-utils.jar:$(findFlinkDistJar) "$ARGS")
dynamic_configs=`extractExecutionParams "$dynamic_configs_output"`
if [[ $? -ne 0 ]]; then
    echo "[ERROR] Could not get dynamic configurations properly."
    exit 1
fi

dynamic_configs=$(echo $dynamic_configs | sed 's/-D //g')
echo "TaskManager Dynamic Configs:"
for config in $(echo "$dynamic_configs" | tr " " "\n")
do
    if [ -z $HUMAN_READABLE ]; then
        echo "    $config"
    else
        human_readable_config=$(translate_to_human_readable $config)
        echo "    $human_readable_config"
    fi
done

