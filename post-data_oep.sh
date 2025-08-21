#!/bin/usr/env bash

source ./config.sh

echo "user: $user"
echo "id_connector: $id_connector"
echo "url_controlplane: $url_controlplane"
echo "url_dataplane: $url_dataplane"
echo "url_dsp: $url_dsp"
echo "api_key: $api_key"

login="User: $a, ID: $id_connector, URL Control: $url_controlplane"
echo $login

url_asset="$url_controlplane/api/management/v3/assets"

echo "Post onto $url_asset"

curl -X POST $url_asset \
    -H "Content-Type: application/json"                         \
    -H "x-api-key: $api_key"                               \
    -d @oep-asset-test.json

echo "Check post (finalization Challenge 1)"

id_asset="oep-test-asset"
url_asset_id="$url_asset/$id_asset"

curl -X GET $url_asset_id \
    -H "x-api-key: $api_key"

echo "Check stop (finalization Challenge 1)"

url_policy="$url_controlplane/api/management/v3/policydefinitions"
echo "Create policy: $url_policy"

curl -X POST $url_policy \
    -H "Content-Type: application/json"                                    \
    -H "x-api-key: $api_key"                                          \
    -d @cc-by-4-policy.json

url_policy_id="$url_policy/cc-by-4"

echo "Check policy (finalization Challenge 2): $url_policy_id"

curl -X GET $url_policy_id \
    -H "x-api-key: $api_key"

url_offer="$url_controlplane/api/management/v3/contractdefinitions"

echo "Create offer: $url_offer"

echo "Add offer: $url_offer"

curl -X POST $url_offer \
    -H "Content-Type: application/json"                                    \
    -H "x-api-key: $api_key"                                          \
    -d @oep-asset-offer.json

url_catalog_request="$url_controlplane/api/management/v3/catalog/request"

echo "Check correct setup of asset, policy and offer (finalization Challenge 3): $url_catalog_request"

curl -X POST $url_catalog_request \
    -H "Content-Type: application/json"                                  \
    -H "x-api-key: $api_key"                                        \
    -d @catalog-request.json | python -mjson.tool

read -p "Press enter to continue"
