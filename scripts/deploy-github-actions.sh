#!/usr/bin/env bash

# Text Color
TXGRN="\033[0;32m" # GREEN
TXNC="\033[0m"

echo
echo -e "${TXGRN}STEP${TXNC} Retrieve Secrets: gcloud secrets versions access"
echo

IFS='#'; read -a envarr <<< $ENVSTR
for varKey in ${envarr[@]}; do
	varValue=`gcloud secrets versions access latest \
    --secret $varKey \
    --format='get(payload.data)' | tr '_-' '/+' | base64 -d`
  runtimeVars+="$varKey: $varValue"$'\n'
  echo "$varKey synced"
done
echo $runtimeVars > env.yaml

echo
echo -e "${TXGRN}STEP${TXNC} Deploy Function: gcloud functions deploy"
echo
gcloud functions deploy $FUNCTION_NAME \
  --entry-point $FUNCTION_NAME \
  --runtime $RUNTIME \
  --memory $MEMORY \
  --timeout $TIMEOUT \
  --trigger-http \
  --env-vars-file env.yaml \
  --allow-unauthenticated \
  --ingress-settings internal-only \
  --egress-settings all \
  --vpc-connector $VPC_CONNECTOR
