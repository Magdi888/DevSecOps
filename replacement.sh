#!/bin/bash
image=$(yq '.spec.template.spec.containers[].image' k8s_deployment_service.yaml)
sed -i 's#${image}#${imageName}#g' k8s_deployment_service.yaml
