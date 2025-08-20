# Documentation Data Space Hackathon Future Energy Lab 2025

Welcome to the Dena Data Space Hackathon at Future Energy Lab 2025.
This documentation describes the individual steps involved in providing and retrieving data in a Data Space.
Each step in this documentation is a so-called `Challenge`.
There are a total of 8 `Challenges` that describe the complete process of data exchange with refinement and subsequent data restoration.

## Preparation

To tackle the individual `Challenges`, you will need an API tool such as `Postman` (a terminal with cUrl is just as good, of course) and the access data for your `Connector`. You will find the latter in the information you have been given. 
In the individual `Challenges`, the necessary API calls are presented as `cUrl`.
A brief explanation of the individual fields in the handouts:

| Feld               | Beispielwert            | Beschreibung                                                                                             |
|--------------------|-------------------------|----------------------------------------------------------------------------------------------------------|
| Connector Identity | fraunhofer-iee          | The unique ID of your `Connector` is required to start negotiations with you.                            |
| Controlplane URL   | https://controlplane... | You can configure your `Connector` at this URL and, for example, make data available in the Data Space.  |
| Dateplane URL      | https://dataplane...    | Other `Connectors` can retrieve negotiated data from you via this URL.                                   |
| DSP URL            | https://dsp...          | This URL is used by two `Connectors` to negotiate contracts.                                             |
| x-api-key          | devpass123456           | The API key required to access the API of your control plane                                             |

Finally, you need the endpoint of your API that provides the data to be shared in the Data Space.
If the API requires authentication, make sure you have taken the necessary precautions.
For example, an `OAuth2 Client` with the appropriate `Client Credentials` or an `API-Key` with the necessary permissions.

The values from the table are used as examples in the descriptions in the `Challenges`. You must replace these with your own values accordingly.

## 1. Challenge - Create an asset for your data

If you don't have a suitable interface, you can skip straight to 
[4. Challenge](#4-challenge---negotiate-a-contract-with-another-data-room-participant).

The `Controlplane's management API` is used for all interactions with the `Connector`.
This API can be used to manage `Assets`, `Policies`, `Offers`, `Contract Negotiations`, and `Data Transfers`.

In the `1st Challenge`, an `Asset` must be created. To do this, the following API call must be made.
```bash
$ curl -X POST https://controlplane.../api/management/v3/assets \
    -H "Content-Type: application/json"                         \
    -H "x-api-key: devpass123456"                               \
    -d @my-asset.json
```

With the corresponding definition of the `Asset`.
```json
{
    "@context": {
        "@vocab": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@id": "my-asset",
    "properties": {
        "name": "My Asset",
        "description": "This is a test asset from Fraunhofer IEE that provides random cat images.",
        "contenttype": "application/json"
    },
    "dataAddress": {
        "type": "HttpData",
        "baseUrl": "https://api.thecatapi.com/v1/images/search",
    }
}
```

- `@context`: Describes the vocabulary currently used for this request.
- `@id`: The unique ID of the `Asset`. A `UUID` is recommended here.
- `properties`: A collection of attributes that can be freely assigned.
    - `name`: Name of the asset.
    - `description`: Brief description of the data provided by this asset.
    - `contenttype`: Format in which the asset data is delivered.
- `dataAddress`: Configures the API interface that delivers the data.
    - `type`: Describes the type of data source. We always use `HttpData` here.
    - `baseUrl`: The URL of the interface that delivers the data. `This must be the endpoint of your API`.

The `dataAddress` field is used to configure how to interact with your interface.
Various other configurations can be made. In the configuration shown here,
all requests to the `Dataplane` for this asset are interpreted as `GET` requests to the configured `baseUrl`.
The `Dataplane` can be seen as a proxy for the actual data-providing APIs.
You can configure whether incoming `Method`, `Query Parameter`, `Path`, or `Body` are also forwarded.
This can be achieved with the following attributes in the `dataAddress` field.
```json
{
    ...
    "dataAddress": {
        "type": "HttpData",
        "baseUrl": "https://api.thecatapi.com/v1/images/search",
        "proxyMethod": "true",
        "proxyPath": "true",
        "proxyQueryParams": "true",
        "proxyBody": "true"
    }
}
```

In this example, the `Method`, an additional `Path` (relative to the `baseUrl`), all `Query Parameters`, and the `Body`
are forwarded to the interface defined by the `baseUrl`.

If your interface requires authentication, the following examples show `Basic Authentication`, an `API Key`
and `Oauth2`. Here, too, all configurations are carried out in the `dataAddress` field.

```json
    ...
    // Basic Authentication
    "dataAddress": {
        "type": "HttpData",
        "baseUrl": "https://api.thecatapi.com/v1/images/search",
        "authKey": "Authorization",
        "authCode": "Basic ZGV2OmRldnBhc3M="
    }
```

```json
    ...
    // API Key
    "dataAddress": {
        "type": "HttpData",
        "baseUrl": "https://api.thecatapi.com/v1/images/search",
        "authKey": "api-key",
        "authCode": "devpass"
    }
```

```json
    ...
    // OAuth2
    "dataAddress": {
        "type": "HttpData",
        "baseUrl": "https://api.thecatapi.com/v1/images/search",
        "oauth2:tokenUrl": "https://api.identity.example/tokens",
        "oauth2:clientId": "my-hackathon-api-client",
        "oauth2:clientSecret": "devpass"
    }
```

The newly created `Asset` can be checked again with the following call:
```bash
$ curl -X GET https://controlplane.../api/management/v3/assets/my-asset \
    -H "x-api-key: devpass123456"
``` 

If the newly created `Asset` is returned, the `1st Challenge` is passed!

## 2. Challenge - Create a policy for your asset

After creating an `Asset`, a `Policy` must be generated.
`Policies` can be used to control who is allowed to view and use which `Assets` in the Data Space.

In the second challenge, you must create a `Policy` that allows all participants to 
view and use your `Asset`. 

To create a `Policy` that can be considered `open-for-all`, the following
call must be made:
```bash
$ curl -X POST https://controlplane.../api/management/v3/policydefinitions \
    -H "Content-Type: application/json"                                    \
    -H "x-api-key: devpass123456"                                          \
    -d @my-policy.json
```

With the corresponding definition of the `Policy`.
```json
{
    "@context": {
        "@vocab": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@id": "all",
    "policy": {
        "@context": "http://www.w3.org/ns/odrl.jsonld",
        "@type": "Set",
        "permission": [],
        "prohibition": [],
        "obligation": []
    }
}
```

- `@context`: Describes the vocabulary currently used for this request.
- `@id`: The unique ID of the `Policy`.
- `policy`: The exact configuration of the `Policy`.
    - `@context`: Describes the vocabulary currently used for this request. At this point, it switches to `odrl`.
    - `@type`: The type of rights and obligations to be configured; this should always be `Set`.
    - `permission`: A list of permissions. This corresponds to a list of “requirements” that must be met by a connector.
    - `prohibition`: A list of prohibitions that a requesting connector must not fulfill. This can also be interpreted as a negated obligation.
    - `obligation`: A list of obligations that a requesting connector must fulfill. E.g., a specific identity.

In the above example, neither `Permissions`, `Prohibitions` nor `Obligations` are defined. As a result, an `Asset` that is linked to this `Policy` via an `Offer` is not subject to any restrictions and can therefore be viewed and used by all Data Space participants.

The newly created `Policy` can be checked again with the following call:
```bash
$ curl -X GET https://controlplane.../api/management/v3/policydefinitions/all \
    -H "x-api-key: devpass123456"
``` 

If the newly created `Policy` is returned, the `2nd Challenge` is passed!

## 3. Challenge - Create an offer for the Asset and publish it in the Data Space

Next, an `Offer` must be created. This links `Assets` with `Policies` and ultimately represents an entry in the Data Space catalog.

To generate an `Offer`, the following call must be made:
```bash
$ curl -X POST https://controlplane.../api/management/v3/contractdefinitions \
    -H "Content-Type: application/json"                                      \
    -H "x-api-key: devpass123456"                                            \
    -d @my-offer.json
```

With the corresponding definition of `Offer`.
```json
{
    "@context": {
        "@vocab": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@id": "my-offer",
    "accessPolicyId": "all",
    "contractPolicyId": "all",
    "assetsSelector": [
        {
            "@type": "https://w3id.org/edc/v0.0.1/ns/Criterion",
            "operandLeft": "id",
            "operator": "=",
            "operandRight": "my-asset"
        }
    ]
}
```

- `@context`: Describes the vocabulary currently used for this request.
- `@id`: The unique ID of the `Offer`.
- `accessPolicyId`: The ID of the `Policy` that controls the visibility of this `Offer`.
- `contractPolicyId`: The ID of the `Policy` that controls the usability of this `Offer`.
- `assetsSelector`: This is used to configure which `Asset` this `Offer` should apply to.
    - `@type`: The type of criterion to be configured for selecting the `Asset`; this should always be defined as above.
    - `operandLeft`: Which field of the `Asset` definition should be used for selection.
    - `operator`: How should the comparison be made, `=` should always be used here.
    - `operandRight`: What value should be in the field defined with `operandLeft`.

As can be seen in the example above, it is entirely possible to define different `Policies` that can be used to control visibility and use in the Data Space. There may well be cases where an `Asset` can be viewed by all participants, but the use of this `Asset` is subject to certain rules.

To check whether everything has been configured correctly, you can query your own catalog with the following command:
```bash
$ curl -X POST https://controlplane.../api/management/v3/catalog/request \
    -H "Content-Type: application/json"                                  \
    -H "x-api-key: devpass123456"                                        \
    -d @catalog-request.json
```

With the corresponding definition of the `Catalog Request`.
```json
{
    "@context": {
        "@vocab": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "counterPartyAddress": "https://dsp.../api/v1/dsp",
    "protocol": "dataspace-protocol-http"
}
```

- `@context`: Describes the vocabulary currently used for this request.
- `counterPartyAddress`: The `DSP URL` of the `Producer` from which the catalog is to be retrieved.
- `protocol`: The underlying protocol that the `Connectors` are to use for exchange; this must always be `dataspace-protocol-http`.

Since we do not want to view the catalog of another `Connector` in this example, but rather our own, it is important to ensure that the `counterPartyAddress` field is filled with your `DSP URL` from the table above.

If you now see your offer in the response in the list `dcat:dataset`, you have passed the `3rd Challenge`!

## 4. Challenge - Negotiate a contract with another Data Space participant

In the previous `Challenges`, your own data was shared in the Data Space. 
Now, data must be retrieved from others so that it can be further processed, for example.
To do this, a contract must first be negotiated. In this process, both 
`Connectors` agree that the `Consumer` accepts the `Producer's` `Policies`.
In this scenario, you are the `Consumer` and another `Connector` from which you retrieve the data
is the `Producer`. In the pervious `Challenges`, you were the `Producer`.

First, you need to retrieve the Data Space catalog to get an overview of all
available `Assets` of all participants. To do this, use the following call:
```bash
$ curl -X POST https://controlplane.../api/catalog/v1alpha/catalog/query \
    -H "Content-Type: application/json"                                  \
    -H "x-api-key: devpass123456"                                        \
    -d @full-catalog-request.json
```

With the corresponding definition of the `Full Catalog Request`.
```json
{
  "@context": {
    "@vocab": "https://w3id.org/edc/v0.0.1/ns/"
  },
  "@type": "QuerySpec"
}
```

- `@context`: Describes the vocabulary currently used for this query.
- `@type`: The type of this catalog query should always be `QuerySpec`.

Since no further restrictions have been imposed by the `QuerySpec`, this query returns all `Assets` of all participants. 
A restriction of this list can be achieved as follows:
```json
{
  "@context": {
    "@vocab": "https://w3id.org/edc/v0.0.1/ns/"
  },
  "@type": "QuerySpec",
  "offset": 0,
  "limit": 20,
}
```

In this example, the first 20 entries in the Data Space catalog are returned.
Entries can be skipped using `offset` and the maximum number can be limited using `limit`.
With an `offset` of 5 and a `limit` of 15, the first 5 `Assets` would be skipped
and the following 15 would be returned.

At this point, it is advisable to select an `Asset` that will also be used in the following `Challenges`
to perform data refinement. If necessary, now is the right time to start exchanging ideas with the other participants 
in the hackathon 😉.

Once it is clear which `Asset` is to be used, these two fields must be taken from the catalog for further queries:
- `dspace:participantId`: The unique `Connector Identity` of the `Producer`.
- `originator`: The `DSP URL` of the `Producer`.
- `dcat:dataset.@id`: The unique ID of the `Asset`.
- `dcat:dataset.odrl:hasPolicy.@id`: A unique ID used for contract negotiations.

For the following calls, we use the following example values for the fields described above for clarification purposes:
- `dspace:participantId`: fraunhofer-iee
- `originator`: https://dsp.../api/v1/dsp
- `dcat:dataset.@id`: my-asset
- `dcat:dataset.odrl:hasPolicy.@id`: dGVzdA==:bXktYXNzZXQ=:ZTM5OTAyM2MtZTMxNy00ZDUzLWEzNjUtZTIzZWZjNTVkNTY5

First, your `Connector (Consumer)` must initiate a negotiation with the `Producer`.
To do this, the following call must be made:
```bash
$ curl -X POST https://controlplane.../api/management/v3/contractnegotiations \
    -H "Content-Type: application/json"                                       \
    -H "x-api-key: devpass123456"                                             \
    -d @contract-negotiation.json
```

With the corresponding definition of `Contract Negotiation`.
```json
{
    "@context": {
        "@vocab": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@type": "ContractRequest",
    "counterPartyAddress": "https://dsp.../api/v1/dsp",
    "protocol": "dataspace-protocol-http",
    "policy": {
        "@context": "http://www.w3.org/ns/odrl.jsonld",
        "@id": "dGVzdA==:bXktYXNzZXQ=:ZTM5OTAyM2MtZTMxNy00ZDUzLWEzNjUtZTIzZWZjNTVkNTY5",
        "@type": "Offer",
        "assigner": "fraunhofer-iee",
        "target": "my-asset"
    }
}
```

- `@context`: Describes the vocabulary currently used for this request.
- `@type`: The type of this request. Since a contract negotiation is to be generated, this must always be `ContractRequest`.
- `counterPartyAddress`: The `DSP URL` of the `Producer` providing the data.
- `protocol`: The underlying protocol that the `Connectors` should use for exchange; this must always be `dataspace-protocol-http`.
- `policy`: This describes that we (the `Consumer`) accept the `Policies` of the `Producer`. Since all `Assets` are generally shared without restrictions, no further specification is required here, except for the following values:
    - `@context`: Describes the vocabulary currently used for this request. At this point, we switch to `odrl`.
    - `@id`: The unique ID of the `Offer`.
    - `@type`: The type of object to which this `ContractRequest` refers; in this case, it is always `Offer`.
    - `assigner`: The `Connector Identity` of the `Producer`.
    - `target`: The unique ID of the `Asset` provided by the `Producer`.

The field `@id` must be copied from the response to this query; it will be used again in the next step.
For this example, we will assume the following value for the field `@id`: `cef31597-67f8-4d1c-aa91-55cbcfe50756`.
This results in the following query, which can be used to view the status of the contract negotiation that was created:
```bash
curl -X GET https://controlplane.../api/management/v3/contractnegotiations/cef31597-67f8-4d1c-aa91-55cbcfe50756 \
    -H "Content-Type: application/json"                                                                         \
    -H "x-api-key: devpass123456"                                                                               \
```

The response to this request includes the `state` field, which indicates whether the negotiation was successful.
If the value of the field is `FINALIZED`, the contract was successfully negotiated. Now you need to save the value
from the `contractAgreementId` field for the next request.

```
If the 'state' has the value 'REQUESTED', even after repeated use of the above request,
this indicates that the value of the 'counterPartyAddress' field may contain a typo.
If the 'state' is set to 'TERMINATED', there is another field called 'errorDetails'. Please get a 
couch to help you fix the error.
```

If you successfully extract the `contractAgreementId` from the previous request, you have passed the `4th Challenge`!

## 5. Challenge - Get the data of another Data Space participant

In this `Challenge`, we will reuse the contract generated in the previous `Challenge` to
start a data transfer. For this, we need the `contractAgreementId`. We can use this 
to retrieve data from the `Producer`. To do this, we start a `Data Transfer` via our `Connector` (`Consumer`)
. We can then retrieve the data via the `Producer's` `Dataplane`.
For the example shown here, we will use the following value for the `contractAgreementId`:
`e84dfae6-a083-47c7-9711-bfeefe993784`.

To do this, we first start the data transfer with the following call:
```bash
$ curl -X POST https://controlplane.../api/management/v3/transferprocesses    \
    -H "Content-Type: application/json"                                       \
    -H "x-api-key: devpass123456"                                             \
    -d @transfer-request.json
```

With the corresponding definition of the `Transfer Request`.
```json
{
    "@context": {
        "@vocab": "https://w3id.org/edc/v0.0.1/ns/"
    },
    "@type": "TransferRequestDto",
    "connectorId": "fraunhofer-iee",
    "counterPartyAddress": "https://dsp.../api/v1/dsp",
    "contractId": "e84dfae6-a083-47c7-9711-bfeefe993784",
    "protocol": "dataspace-protocol-http",
    "transferType": "HttpData-PULL"
}
```

- `@context`: Describes the vocabulary currently used for this request.
- `@type`: The type of this request. Since a data transfer is to be generated, this must always be `TransferRequestDto`.
- `connectorId`: The `Connector Identity` of the `Producer`.
- `counterPartyAddress`: The `DSP URL` of the `Producer` providing the data.
- `contractId`: The `contractAgreementId` from the previous `Challenge`.
- `protocol`: The underlying protocol that the `Connectors` should use for exchange; this must always be `dataspace-protocol-http`.
- `transferType`: The type of this data transfer. Since we want to retrieve the data, we use `HttpData-PULL`.

As with the contract negotiation from the previous `Challenges`, the field `@id` must also be copied from the response in this call in order to view the status 
of the transfer process. In this example, we assume the following value for `@id`: `d50c05cd-0ad8-482f-b547-57273be3c545`.

This results in the following call, which can be used to view the status of the transfer process that has just been created:
```bash
$ curl -X GET https://controlplane.../api/management/v3/transferprocesses/d50c05cd-0ad8-482f-b547-57273be3c545 \ 
    -H "Content-Type: application/json"                                                                        \
    -H "x-api-key: devpass123456"                                                                              \
```

In this query, the `state` field in the response is also the indicator for a successful data transfer.
If the field has the value `STARTED`, the data transfer was started successfully.

```
If the 'state' has the value 'REQUESTED', even after repeated use of the above request,
this indicates that the value of the 'counterPartyAddress' field may contain a typo.
If the 'state' is set to 'TERMINATED', there is another field called 'errorDetails'. Please get a 
couch to help you fix the error.
```

The next step is to obtain the information about the endpoint from which we can retrieve the data.
This is referred to as the `Endpoint Data Reference (EDR)` in the Data Space. To do this, we again need the `@id` of the
started data transfer. The following query provides us with the information we need to retrieve the data:
```bash
$ curl -X GET https://controlplane.../api/management/v3/edrs/d50c05cd-0ad8-482f-b547-57273be3c545/dataaddress \ 
    -H "Content-Type: application/json"                                                                       \
    -H "x-api-key: devpass123456"                                                                             \
```

We need the following fields from the response to this query in order to retrieve data:

- `endpoint`: Die Adresse der `Dataplane` des `Producer` welche angefragt werden muss, um Daten zu bekommen.
- `authType`: Der für die Authorization benötige Authorizationstyp, in diesem Fall ist dies immer `bearer`
- `authorization`: Das `bearer token` welches bei der Anfragen an den `Endpoint` mitgesendet werden muss.

These fields result in the following sample query to retrieve the previously negotiated data:
```bash
$ curl -X GET https://dataplane.../api/v2/public                         \
    -H "Content-Type: application/json"                                  \
    -H "Authorization: eyJraWQiOiJ2ZXJpZmllci1rZXkiLC...KP3tMbXWx7Q98wg"
```

If you receive data in response to this call, you have passed the `5th Challenge`!

## 6. Challenge - Refine the collected data

In this step, the data from the previous `Challenge` should be processed and refined in some way.
This could be aggregation or simple averaging, for example.
In order to be able to process the data further in a script, the `Dataplane Endpoint` from the previous step of the previous `Challenge` must be integrated.
This is done by copying the `Dataplane Endpoint` from the previous `Challenge` into the script.

This `Challenge` is part of the `Pitch` and should be presented there.
Once this `Challenge` has been presented, it is considered passed!

## 7. Challenge - Make the refined data available again in the Data Space for others

In this `Challenge`, the refined data from the previous `Challenge` should be made available again in the Data Space.
To do this, `Challenges 1 to 3` can be repeated with the refined data.

This `Challenge` is considered complete when the final steps from `Challenge 3` have been repeated and the new 
`Asset` is visible in the catalog!

## 8. Challenge - Create a visualization of the refined data

In the final `Challenge`, you will be asked to create a visualization of your refined data.
This can be done in any form you like, whether using Python or a web app.

The `8th Challenge` is considered complete once you have presented your visualization in the `Pitch`!
