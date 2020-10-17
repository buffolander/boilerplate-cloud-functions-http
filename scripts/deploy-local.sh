#!/usr/bin/env bash

echo
echo -e "${TXGRN} STEP${TXNC} Authenticate Service Account: gcloud auth activate-service-account"
echo
gcloud auth activate-service-account $SERVICE_ACCT_EMAIL \
  --key-file $SERVICE_ACCT_KEYFILE_PATH \
  --project $PROJECT
echo
echo -e "${TXGRN} STEP${TXNC} Deploy Function: gcloud functions deploy"
echo
gcloud functions deploy $STAGE-$FUNCTION_NAME \
  --entry-point $FUNCTION_NAME \
  --runtime $RUNTIME \
  --memory $MEMORY \
  --timeout $TIMEOUT \
  --trigger-http \
  --set-env-vars $(IFS=$','; echo "${envarr[*]}") \
  --allow-unauthenticated \
  # --ingress-settings all
  --ingress-settings internal-only \
  --egress-settings all \
  --vpc-connector $VPC_CONNECTOR
