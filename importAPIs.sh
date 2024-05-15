#! /bin/bash

# NOTE: Create the following environment variables before running
# export USER_NAME=test
# export PASSWORD='test'
# export USER_NAME1=test1
# export PASSWORD1='test1'
# export CLIENT_ID=demo-restapi-client-app1
# export CLIENT_SEC=test2


# Endpoints
# export PLATFORM_API=test.../apis/cp4i/small
# export API_MANAGER=test23423

# Identity providers
export ADMIN_IDP=default-idp-1
export PORG_IDP=default-idp-2

# Provider organization
export PORG=test1

# -------------------------------------
# Get admin bearer token
# -------------------------------------
admin_token=$(curl --location --request POST -k "https://$PLATFORM_API/api/token" --header "Content-Type: application/json" --header "Accept: application/json" --data-raw "{\"username\": \"$USER_NAME\",\"password\": \"$PASSWORD\",\"realm\": \"admin/$ADMIN_IDP\",\"client_id\": \"$CLIENT_ID\",\"client_secret\": \"$CLIENT_SEC\",\"grant_type\": \"password\"}" | jq .access_token | sed -e s/\"//g)

# -------------------------------------
# Get organizations
# -------------------------------------
orgs=$(curl --location --request GET -k "https://$PLATFORM_API/api/cloud/orgs" --header "Authorization: Bearer $admin_token" --header "Accept: application/json")

# NOTE: The logic for selecting the provider organization should be placed here
# For the sake of simplification of the demo we will use hardcoded provider organization name

# -------------------------------------
# Get provider organization token
# -------------------------------------
provider_token=$(curl --location --request POST -k "https://$PLATFORM_API/api/token" --header "Content-Type: application/json" --header "Accept: application/json" --data-raw "{\"username\": \"$USER_NAME1\",\"password\": \"$PASSWORD1\",\"realm\": \"provider/$PORG_IDP\",\"client_id\": \"$CLIENT_ID\",\"client_secret\": \"$CLIENT_SEC\",\"grant_type\": \"password\"}" | jq .access_token | sed -e s/\"//g)


# -------------------------------------
# Import API
# -------------------------------------

demo_api=`yq eval -o=j ./inventory_1.0.0.yaml`

draft_api=$(curl --location --request POST -k "https://$PLATFORM_API/api/orgs/$PORG/drafts/draft-apis" --header "Accept: application/json" --header "content-type: application/json" --header "Authorization: Bearer $provider_token" --data-raw "{\"draft_api\":$demo_api}" )

echo $draft_api



# -------------------------------------
# List draft APIs and Products in the 
# selected provider organization
# -------------------------------------

curl --location --request GET -k "https://$PLATFORM_API/api/orgs/$PORG/drafts" --header "Accept: application/json" --header "Authorization: Bearer $provider_token"






















