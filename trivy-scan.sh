#!/bin/bash

ImageName=$(awk 'NR==1 {print $}' Dockerfile)

trivy image --severity HIGH --exit-code 0 --light $ImageName
trivy image --severity CRITICAL --exit-code 1 --light $ImageName

exit-code=$?

if [[ $exit-code == 1 ]]
    then
        echo "Image Scanning failed, Vulnerabilities found"
        exit 1;
    else
        echo "Image Scanning passed, No Critical Vulnerabilies found"
    fi