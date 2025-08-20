#!/bin/usr/env bash
a='reinersDatenzentrum'
id_connector='reiners-datenzentrum'
url_controlplane='https://reinersdatzen-controlplane.hackathon.future-energy-dialog.de'
url_dataplane='https://reinersdatzen-dataplane.hackathon.future-energy-dialog.de'
url_dsp='https://reinersdatzen-controlplane.hackathon.future-energy-dialog.de/api/v1/dsp'
api_key='TrBp2qPJewwjVAjxlIOj'

login="User: $a, ID: $id_connector, URL Control: $url_controlplane"
echo $login

curl -X POST https://reinersdatzen-controlplane.hackathon.future-energy-dialog.de \
    -H "Content-Type: application/json"                         \
    -H "x-api-key: TrBp2qPJewwjVAjxlIOj"                               \
    -d @my-asset.json

read -p "Press enter to continue"