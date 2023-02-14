#!/bin/bash

ImageName=$(awk 'NR==1 {print $2}' Dockerfile)

trivy -q image  --timeout 50m0s --severity HIGH --exit-code 0  $ImageName
trivy -q image  --timeout 50m0s --severity CRITICAL --exit-code 1  $ImageName

exit_code=$?

if [[ $exit_code == 1 ]]
    then
        echo "Image Scanning failed, Vulnerabilities found"
        exit 1;
    else
        echo "Image Scanning passed, No Critical Vulnerabilies found"
    fi