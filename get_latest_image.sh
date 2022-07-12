#!/bin/bash

set -e

if [ "$#" -ne 5 ]; then
    echo "Usage: get_latest_image.sh <VIO auth URL> <VIO username> <VIO password> <VIO project> <BIG-IP Next Release>"
    exit 1;
fi

export OS_AUTH_URL=$1
export OS_USERNAME=$2
export OS_PASSWORD=$3
export OS_PROJECT_NAME=$4
BIG_IP_NEXT_RELEASE=$5

vio image list --mbip --release "${BIG_IP_NEXT_RELEASE}" | jq '.[-1] | {id: .id}'
