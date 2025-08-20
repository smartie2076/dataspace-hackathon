#!/bin/usr/env bash
user='reinersDatenzentrum'
id_connector='reiners-datenzentrum'
url_controlplane='https://reinersdatzen-controlplane.hackathon.future-energy-dialog.de'
url_dataplane='https://reinersdatzen-dataplane.hackathon.future-energy-dialog.de'
url_dsp='https://reinersdatzen-controlplane.hackathon.future-energy-dialog.de/api/v1/dsp'
api_key='TrBp2qPJewwjVAjxlIOj'

login="User: $a, ID: $id_connector, URL Control: $url_controlplane"
echo $login

url_catalog_query="$url_controlplane/api/catalog/v1alpha/catalog/query"

echo "Access all available data (or rather, 25 items): $url_catalog_query"

curl -X POST $url_catalog_query \
    -H "Content-Type: application/json"                                  \
    -H "x-api-key: $api_key"                                        \
    -d @full-catalog-request.json | python -mjson.tool

target_asset_id='openmeter-measurements-by-sensorid'
target_asset_participant_id='fraunhofer-iee'
target_asset
echo

read -p "Press enter to continue"