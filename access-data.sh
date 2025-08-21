#!/bin/usr/env bash

# Definition of variables
source ./config.sh

echo "user: $user"
echo "id_connector: $id_connector"
echo "url_controlplane: $url_controlplane"
echo "url_dataplane: $url_dataplane"
echo "url_dsp: $url_dsp"
echo "api_key: $api_key"

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
# Data on generation capacities per community
target_asset_id='mastr-geodata-asset'
target_asset_participant_id='offis'
target_asset_policy_handle='bGV0enRlcy1hbmdlYm90:bWFzdHItZ2VvZGF0YS1hc3NldA==:ODVjY2I0OTEtZGMyZC00MzVkLTg1YzAtNmFiNGUyZDMwNDEy'
target_asset_originator='https://offis-controlplane.hackathon.future-energy-dialog.de/api/v1/dsp'

# Household-level demand data, not working
# target_asset_id='openmeter-measurements-by-sensorid'
# target_asset_participant_id='fraunhofer-iee'
# target_asset_originator='https://fhiee-controlplane.hackathon.future-energy-dialog.de/api/v1/dsp'
# target_asset_policy_handle='YWxs:b3Blbm1ldGVyLW1lYXN1cmVtZW50cy1ieS1zZW5zb3JpZA==:NDI5Yjk3NzYtNTYwNC00NTM0LTkzMDEtY2Y2ODZhZjE4ZDkw'

echo -e "\nStart negotiation with producer $target_asset_participant_id of asset $target_asset_id"

url_negotiation="$url_controlplane/api/management/v3/contractnegotiations"

# Update negotation according to requested data
python -c "import json, sys; data=json.load(open('contract-negotiation.json')); data['counterPartyAddress']=sys.argv[1]; data['policy']['@id']=sys.argv[2]; data['policy']['target']=sys.argv[3]; data['policy']['assigner']=sys.argv[4]; json.dump(data, open('contract-negotiation.json', 'w'), indent=4)" "$target_asset_originator" "$target_asset_policy_handle" "$target_asset_id" "$target_asset_participant_id"


# This negotiation/offer will have a NEW ID every time the code is executed
curl -X POST $url_negotiation \
    -H "Content-Type: application/json"                                       \
    -H "x-api-key: $api_key"                                             \
    -d @contract-negotiation.json > negotiation.json

# Processing time on server necessary
sleep 10

# Access negotiation ID to later ask for updates
negotiation_id=$(python -c "import json; print(json.load(open('negotiation.json'))['@id'])" )
echo "Negotiations are started with ID (Challenge 4) $negotiation_id"

# See if contract is confirmed
curl -X GET "$url_negotiation/$negotiation_id" \
    -H "Content-Type: application/json"                                                                         \
    -H "x-api-key: $api_key"  > negotiation_agreement.json

# Get contract ID
negotiation_agreement_id=$(python -c "import json; print(json.load(open('negotiation_agreement.json'))['contractAgreementId'])" )

echo -e "Negotiations are finalized with contract ID (Challenge 4) $negotiation_agreement_id\n"

# Challenge 5

echo "Update transfer-request.json according to contract"
# Access id of negotiation/contract from previous response, update template transfer-request.json
python -c "import json, sys; data=json.load(open('transfer-request.json')); data['contractId']=sys.argv[1]; json.dump(data, open('transfer-request.json', 'w'), indent=4)" "$negotiation_agreement_id"

url_transfer="$url_controlplane/api/management/v3/transferprocesses"

# update transfer request according to requested data
python -c "import json, sys; data=json.load(open('transfer-request.json')); data['counterPartyAddress']=sys.argv[1]; data['connectorId']=sys.argv[2]; json.dump(data, open('transfer-request.json', 'w'), indent=4)" "$target_asset_originator" "$target_asset_participant_id"

# initalize transfer process
curl -X POST $url_transfer    \
    -H "Content-Type: application/json"                                       \
    -H "x-api-key: $api_key"                                             \
    -d @transfer-request.json > transfer_process.json

transfer_process_id=$(python -c "import json; print(json.load(open('transfer_process.json'))['@id'])" )

# Check if transfer process status is "Started"
curl -X GET "$url_transfer/$transfer_process_id" \
    -H "Content-Type: application/json"                                                                        \
    -H "x-api-key: $api_key" > transfer_process.json

status=$(python -c "import json; print(json.load(open('transfer_process.json'))['state'])")
echo "Transfer process status: $status (ID: $transfer_process_id)"

# Access transfer status regularly until process finished
counter=0
while [ "$status" != "STARTED" ]
#while [ "$status" != "FINALIZED" ]
do
    # Processing time on server necessary
    sleep 30
    curl -X GET "$url_transfer/$transfer_process_id" \
        -H "Content-Type: application/json"                                                                        \
        -H "x-api-key: $api_key" > transfer_process.json
    status=$(python -c "import json; print(json.load(open('transfer_process.json'))['state'])")
    echo "... $status"
    ((counter++))
done

echo "Time until status finished: $counter*30 Seconds"

# Access information to fetch data
curl -X GET "$url_controlplane/api/management/v3/edrs/$transfer_process_id/dataaddress" \
    -H "Content-Type: application/json"                                                                       \
    -H "x-api-key: $api_key" > transfer_adress.json

url_endpoint=$(python -c "import json; print(json.load(open('transfer_adress.json'))['endpoint'])")
url_auth=$(python -c "import json; print(json.load(open('transfer_adress.json'))['authorization'])")

curl -X GET $url_endpoint                        \
    -H "Content-Type: application/json"                                  \
    -H "Authorization: $url_auth" > data.json

echo -e "The data $target_asset_id of provider $target_asset_originator has successfully been stored in data.json (Challenge 5 completed)."

read -p "Press enter to continue"