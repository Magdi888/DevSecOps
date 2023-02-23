#!/bin/bash

PORT=$(kubectl get svc devsecops-svc -o=jsonpath='{.spec.ports[*].nodePort}')

docker container run --rm -u 0 -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-weekly zap-api-scan.py -t $appURL:$PORT/v3/api-docs -f openapi  -r zap_report.html

exit_code=$?

mkdir -p owasp-zap-report
mv zap_report.html owasp-zap-report

if ! [[ $exit_code == 0 ]]
then
    echo "OWASP ZAP Report has Low/Medium/High Risk. Please check HTML Report"
    exit 1;
else
    echo "OWASP ZAP did not  report any Risk"
fi


