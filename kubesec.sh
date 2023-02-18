#!/bin/bash

kubesecResult=$(curl -sSX POST --data-binary @"k8s_deployment_service.yaml" https://v2.kubesec.io/scan)
kubesecMessage=$(curl -sSX POST --data-binary @"k8s_deployment_service.yaml" https://v2.kubesec.io/scan | jq .[0].message -r)
kubesecScore=$(curl -sSX POST --data-binary @"k8s_deployment_service.yaml" https://v2.kubesec.io/scan | jq .[0].score)

if [[ $kubesecScore -ge 5 ]]
then
    echo "Score is $kubesecScore"
    echo "Kubescan $kubesecMessage"
else
    echo "Score is $kubesecScore , whish is less than 5"
    echo "Scanning K8S Resources has Failed"
    exit 1;
fi


