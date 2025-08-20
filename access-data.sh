#!/bin/usr/env bash

# Definition of variables
user='reinersDatenzentrum'
id_connector='reiners-datenzentrum'
url_controlplane='https://reinersdatzen-controlplane.hackathon.future-energy-dialog.de'
url_dataplane='https://reinersdatzen-dataplane.hackathon.future-energy-dialog.de'
url_dsp='https://reinersdatzen-controlplane.hackathon.future-energy-dialog.de/api/v1/dsp'
api_key='TrBp2qPJewwjVAjxlIOj'

login="User: $a, ID: $id_connector, URL Control: $url_controlplane"
echo $login

# Challenge 4
url_catalog_query="$url_controlplane/api/catalog/v1alpha/catalog/query"

echo "Access all available data (or rather, 25 items): $url_catalog_query"

# Get data of catalogue, change full-catalog-request.json to get more entries
curl -X POST $url_catalog_query \
    -H "Content-Type: application/json"                                  \
    -H "x-api-key: $api_key"                                        \
    -d @full-catalog-request.json > data_catalog.json

# pretty print to file
python -c "import json; data=json.load(open('data_catalog.json')); json.dump(data, open('data_catalog.json', 'w'), indent=4)"

# Hand-copied from interesting entries! This entries are not changing.
target_asset_id='mastr-geodata-asset'
target_asset_participant_id='offis'
target_asset_policy_handle='bGV0enRlcy1hbmdlYm90:bWFzdHItZ2VvZGF0YS1hc3NldA==:ODVjY2I0OTEtZGMyZC00MzVkLTg1YzAtNmFiNGUyZDMwNDEy'
target_asset_originator='https://offis-controlplane.hackathon.future-energy-dialog.de/api/v1/dsp'

# This dataset was too big and took a very long time to transfer
#target_asset_id='openmeter-measurements-by-sensorid'
#target_asset_participant_id='fraunhofer-iee'
#target_asset_originator='https://fhiee-controlplane.hackathon.future-energy-dialog.de/api/v1/dsp'
#target_asset_policy_handle='YWxs:b3Blbm1ldGVyLW1lYXN1cmVtZW50cy1ieS1zZW5zb3JpZA==:NDI5Yjk3NzYtNTYwNC00NTM0LTkzMDEtY2Y2ODZhZjE4ZDkw'

echo "Start negotiation with producer $target_asset_participant_id of asset $target_asset_id"

url_negotiation="$url_controlplane/api/management/v3/contractnegotiations"

curl -X POST $url_negotiation \
    -H "Content-Type: application/json"                                       \
    -H "x-api-key: $api_key"                                             \
    -d @contract-negotiation.json > negotiation.json

# Processing time on server necessary
sleep 10

sleep 20

negotiation_id=$(python -c "import json; print(json.load(open('negotiation.json'))['@id'])" )
echo "Negotiations are started with ID $negotiation_id"

# See if contract is confirmed
curl -X GET $url_negotiation/$negotiation_id \
    -H "Content-Type: application/json"                                                                         \
    -H "x-api-key: $api_key"  | python -mjson.tool

read -p "Press enter to continue"