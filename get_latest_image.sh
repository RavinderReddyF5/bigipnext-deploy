#!/bin/bash

set -e

if [ "$#" -ne 3 ]; then
    echo "Usage: get_latest_image.sh <VIO username> <VIO password> <VIO project>"
    exit 1;
fi

export OS_USERNAME=$1
export OS_PASSWORD=$2
export OS_PROJECT_NAME=$3

vio image list --mbip | jq '.[-1] | {id: .id}'
