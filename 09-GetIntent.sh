#!/bin/bash

# Set values for your Language Understanding app
app_id=YOUR_APP_ID
endpoint=YOUR_ENDPOINT
key=YOUR_KEY

# Get parameter and encode spaces for URL
input=$1
query=${input//' '/%20}

# Use cURL to call the REST API
URL="$endpoint/luis/prediction/v3.0/apps/$app_id/slots/production/predict?subscription-key=$key&log=true&query=$query"
curl -X GET $URL

echo -e "\n"
