#!/bin/bash

set -e

# Ensure all the required tools are installed

for tool in git jq yq kubectl curl; do
    if hash "$tool" &> /dev/null
    then
        continue
    else
        echo "Mandatory tool: $tool is not installed"
        exit 1
    fi
done

eval set -- "$options"
sleep 5
KUBE_CONFIG=/root/.kube/config

echo "INJECTIONS_LIST: ${INJECTIONS_LIST}"

[[ -z "${NAMESPACE}" ]] && NAMESPACE='default' || NAMESPACE="${NAMESPACE}"
[[ -z "${ENV1}" ]] && ENV1='Hello' || ENV1="${ENV1}"
[[ -z "${ENV2}" ]] && ENV2='It is a shinny day!' || ENV2="${ENV2}"

#Exporting environment variables
export ENV1
export ENV2
export NAMESPACE

# Function used to patch the deployment
function patch_deployment(){
local DEPLOY="$1"
    config="spec:
      template:
        spec:
          imagePullSecrets:
          - name: ${IMAGEPULLSECRET}
          containers:
          - name: collector
            image: \<path-to-container-registry\>
            env:
            - name: "ENV1"
              value:  \"${ENV1}\"
            - name: "ENV2"
              value:  \"${ENV2}\"
            imagePullPolicy: Always
            "
    config_edited=$(echo "$config" | yq '(.. | select(tag == "!!str")) |= envsubst')
    kubectl --kubeconfig=${KUBE_CONFIG} -n ${NAMESPACE}  patch deploy $DEPLOY --patch "$config_edited"
}

echo "[1] Injection mechanism started"
components=$(kubectl --kubeconfig=${KUBE_CONFIG} -n ${NAMESPACE}  get deploy -o jsonpath="{.items..metadata.name}")

IFS=' ' read -r -a injections_list_aux <<< "$INJECTIONS_LIST"

# List the existent deployments in the namespace and proceed with the patch
for DEPLOY in ${injections_list_aux[@]}
do
  if [[ " ${components[@]} " =~ " $DEPLOY " ]]
  then
    echo "Handling component: $DEPLOY"
    patch_deployment "${DEPLOY}"
  else
    echo "ERROR: Application does not exist in namespace. Exiting..."
    exit 2
  fi
done

echo "[2] Injection mechanism completed successfully!"
