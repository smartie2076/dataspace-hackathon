#!/bin/usr/env bash
a='reinersDatenzentrum'
id_connector='reiners-datenzentrum'
url_controlplane='https://reinersdatzen-controlplane.hackathon.future-energy-dialog.de'
url_dataplane='https://reinersdatzen-dataplane.hackathon.future-energy-dialog.de'
url_dsp='https://reinersdatzen-controlplane.hackathon.future-energy-dialog.de/api/v1/dsp'
api_key='TrBp2qPJewwjVAjxlIOj'

login="User: $a, ID: $id_connector, URL Control: $url_controlplane"
echo $login

asset_name='my-asset'
url_asset="$url_controlplane/api/management/v3/$asset_name"

echo "Post onto $url_asset"

curl -X POST $url_asset \
    -H "Content-Type: application/json"                         \
    -H "x-api-key: $api_key"                               \
    -d @my-asset.json

echo "Check post"

curl -X GET $url_asset \
    -H "x-api-key: $api_key"

read -p "Press enter to continue"