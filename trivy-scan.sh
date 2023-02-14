#!/bin/bash

ImageName=$(awk 'NR==1 {print $2}' Dockerfile)

trivy -q image  --timeout 20m0s --severity HIGH --exit-code 0 -q $ImageName
trivy -q image  --timeout 20m0s --severity CRITICAL --exit-code 1 -q $ImageName

exit-code=$?

if [[ $exit-code == 1 ]]
    then
        echo "Image Scanning failed, Vulnerabilities found"
        exit 1;
    else
        echo "Image Scanning passed, No Critical Vulnerabilies found"
    fi