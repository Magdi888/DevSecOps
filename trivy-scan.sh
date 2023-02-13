#!/bin/bash

ImageName=$(awk 'NR==1 {print $2}' Dockerfile)

trivy image --no-progress --scanners vuln --severity HIGH --exit-code 0  $ImageName
trivy image --no-progress --scanners vuln --severity CRITICAL --exit-code 1  $ImageName

exit-code=$?

if [[ $exit-code == 1 ]]
    then
        echo "Image Scanning failed, Vulnerabilities found"
        exit 1;
    else
        echo "Image Scanning passed, No Critical Vulnerabilies found"
    fi