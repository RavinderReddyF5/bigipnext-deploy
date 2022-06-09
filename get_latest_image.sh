#!/bin/bash

set -e

if [ "$#" -ne 4 ]; then
    echo "Usage: get_latest_image.sh <VIO username> <VIO password> <VIO project> <BIG-IP Next Release>"
    exit 1;
fi

export OS_USERNAME=$1
export OS_PASSWORD=$2
export OS_PROJECT_NAME=$3
BIG_IP_NEXT_RELEASE=$4

vio image list --mbip --release "${BIG_IP_NEXT_RELEASE}" | jq '.[-1] | {id: .id}'
