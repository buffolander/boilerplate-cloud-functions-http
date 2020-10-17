#!/usr/bin/env bash

# Text Color
TXRED="\033[0;31m" # RED
TXGRN="\033[0;32m" # GREEN
TXYLW="\033[0;33m" # YELLOW
TXBLU="\033[0;34m" # BLUE
TXMAG="\033[0;35m" # MAGENTA
TXCYA="\033[0;36m" # CYAN
# Background Color
BGRED="\033[0;41m" # RED
BGGRN="\033[0;42m" # GREEN
BGYLW="\033[0;43m" # YELLOW
BGBLU="\033[0;44m" # BLUE
BGMAG="\033[0;45m" # MAGENTA
BGCYA="\033[0;46m" # CYAN
# No Color
TXNC="\033[0m"

getvar () {
  IFS='#'
  read -a cmtarr <<< "$line"
  var=`echo ${cmtarr[0]} | xargs`
}

splitvar () {
  IFS='='
  read -a vararr <<< "$var"
  var=`echo ${vararr[0]} | xargs`
}

while getopts ":e:p:" opt; do
  case $opt in
    e) env=`echo "$OPTARG"  | awk '{print tolower($0)}'`;;
  esac
done

processingDeploymentVars=0
processingRuntimeVars=0
envarr=()

while read line; do
  if [[ $line == *"DEPLOYMENT_VARIABLES"* ]]; then
    processingDeploymentVars=1
  elif [[ $line == *"RUNTIME_VARIABLES"* ]]; then
    processingRuntimeVars=1
  elif [[ $line == "#"* || $line == "" ]]; then
    : # ignored; only comments
  elif [[ $processingDeploymentVars -eq 1 && $processingRuntimeVars -eq 0 ]]; then
    getvar
    if [[ $env == "live" && $var == "STAGE"* ]]; then
      export STAGE=$env
      echo "STAGE=$env" >> $GITHUB_ENV
    else
      export $var
      echo $var >> $GITHUB_ENV
    fi
  elif [[ $processingRuntimeVars -eq 1 && $STAGE == 'dev' ]]; then
    getvar
    envarr+=($var)
  elif [[ $processingRuntimeVars -eq 1 && $STAGE == 'live' ]]; then
    getvar
    splitvar
    envarr+=($var)
    echo "ENVSTR=$(IFS=$'#'; echo "${envarr[*]}")" >> $GITHUB_ENV
  else
    : # ingored
  fi
done < .env

$(clear >&2)
echo
echo -e "${TXGRN}STEP${TXNC} Preparing Deployment STAGE=$STAGE"
echo 
echo functionName: $FUNCTION_NAME
echo runtime: $RUNTIME
echo maxAllocatedMemory: $MEMORY
echo executionTimeout: $TIMEOUT
echo runtimeVariables: $(IFS=$','; echo "${envarr[*]}")
echo vpcConnector: $VPC_CONNECTOR
echo –––
echo project: $PROJECT
echo projectNumber: $PROJECT_NO
echo serviceAccountEmail: $SERVICE_ACCT_EMAIL
echo serviceAccountPath: $SERVICE_ACCT_KEYFILE_PATH

if [[ $STAGE == 'live' ]]; then
  echo
  echo -e "${TXYLW}AUTH${TXNC} github-actions/setup-gcloud@master..."
  exit 0
fi

source scripts/deploy-local.sh
