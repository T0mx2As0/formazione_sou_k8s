#!/bin/sh

serviceaccount=""
namespace=""
app_name='$(minikube kubectl get deploy -n formazione-sou --no-headers |  cut -d " " -f 1)'
url_api='$(minikube kubectl config view | grep server | tr -s "  " | cut -d " " -f 3)'


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

token='$(minikube kubectl create token $serviceaccount -n $namespace)'

deploy='$(curl -s --insecure -X GET \
   -H "Authorization: Bearer $token" \
   -H "Accept: application/json" \
   $url_api/apis/apps/v1/namespaces/$namespace/deployments/$app_name )'

live_probe='$(cat $deploy | jq '.spec.template.spec.containers[0].livenessProbe' | grep -v null)'
ready_probe='$(cat $deploy | jq '.spec.template.spec.containers[0].readinessProbe' | grep -v null)'
limits='$(cat $deploy | jq '.spec.template.spec.containers[0].resources.limits' | grep -v null)'
requests='$(cat $deploy | jq '.spec.template.spec.containers[0].resources.requests' | grep -v null)'

if [[ -n "$live_probe" && -n "$ready_probe" && -n "$limits" && -n "$requests" ]]; then 
    echo "Il deployment rispetta tutti i requisiti"
else
    echo "Il deployment non rispetta i requisiti"
fi
