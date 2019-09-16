#!/bin/bash -ex

cd "$( dirname "${BASH_SOURCE[0]}" )"

trap "vagrant destroy -f" EXIT

curl "${VMCK_ARCHIVE_URL}" -o submission.zip
curl "${VMCK_SCRIPT_URL}" -o checker.sh

vagrant up
vagrant ssh -- < checker.sh > result.out

data="$(base64 result.out)"
JSON_STRING=$(jq -n \
                 --arg out "$data" \
                 '{output: $out,}')
curl -X POST "${VMCK_CALLBACK_URL}" -d "$JSON_STRING" \
     --header "Content-Type: application/json"
