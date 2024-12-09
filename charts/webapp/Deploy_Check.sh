# curl --insecure -X GET \
#   -H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6ImtaNW43VUEtdFFhMW51b2ZLNE53Q1I5Zk94Z1FPeGRsZno3Q0ZmVkR1Vm8ifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNzMzNjgxOTY0LCJpYXQiOjE3MzM2NzgzNjQsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwianRpIjoiODk5OTQzNjYtYmZjZi00NDhlLWFhY2ItZTNhMTJlNzAzYzU3Iiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJmb3JtYXppb25lLXNvdSIsInNlcnZpY2VhY2NvdW50Ijp7Im5hbWUiOiJzYS1jbHVzdGVyLXJlYWRlciIsInVpZCI6ImRlYmQwMWIzLTFhZjctNGE0OS05YzEyLTMxNjk1MDhmMDk0OCJ9fSwibmJmIjoxNzMzNjc4MzY0LCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6Zm9ybWF6aW9uZS1zb3U6c2EtY2x1c3Rlci1yZWFkZXIifQ.e4sH6Pm7A_Px_EqkeiLVY6617d0qvyACq9H9pVNM_IETqa9ynskBrlB4mu1O9ywVOCnbwKAqgyQ3wgBh9-zOsB3oyqDAlucRjEygw8U6wFiADU8lHbyliIEIO4wVU2jy84A2T_CC4QbW3eOE3ZpEDscvvtAnQbu3ZxVXgDKgAF76oVt2iGi3GuLNymAXdg5L4ww8wCEi8wZuvtYTC2A0xejLZ7-Yndhn8JMW9QKMlG3zvBpHPkKeYJqL-rmi5JQIkR1QKyzkca3t07aIzK5Fz-v5lFmS8YAQJa5Qwtk8bCoiCt68ub5oAQ6hEBsoAW16wJzhC2UEDChf6V2QCrEMLQ" \
#   -H "Accept: application/json" \
#   https://127.0.0.1:49912/apis/apps/v1/namespaces/formazione-sou/deployments/webapp-deploy

#!/bin/bash

serviceaccount=""
namespace=""
app_name=$(kubectl get deploy -n formazione-sou --no-headers |  cut -d " " -f 1)
url_api=$(kubectl config view | grep server | tr -s "  " | cut -d " " -f 3)


while getopts "s:n:" opt; do
    case "$opt" in
        s) 
            serviceaccount="$OPTARG"
            ;;
        n) 
            namespace="$OPTARG"
            ;;
    esac
done

token=$(kubectl create token $serviceaccount -n $namespace)

deploy=$(curl -s --insecure -X GET \
   -H "Authorization: Bearer $token" \
   -H "Accept: application/json" \
   $url_api/apis/apps/v1/namespaces/$namespace/deployments/$app_name )

live_probe=$(cat test.yaml | jq '.spec.template.spec.containers[0].livenessProbe' | grep -v null)
ready_probe=$(cat test.yaml | jq '.spec.template.spec.containers[0].readinessProbe' | grep -v null)
limits=$(cat test.yaml | jq '.spec.template.spec.containers[0].resources.limits' | grep -v null)
requests=$(cat test.yaml | jq '.spec.template.spec.containers[0].resources.requests' | grep -v null)

if [[ -n "$live_probe" && -n "$ready_probe" && -n "$limits" && -n "$requests" ]]; then 
    echo "Il deployment rispetta tutti i requisiti"
else
    echo "Il deployment non rispetta i requisiti"
fi