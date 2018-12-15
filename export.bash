#!/ Bin bash
echo "Exporting ns ,except default and system"
kubectl get --export -o=json ns |  
jq '.items[] | select(.metadata.name!="kube-system") | select(.metadata.name!="default") | del(.status, .metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation )' > ./cluster-dump/ns.json
cat ./cluster-dump/ns.json





echo "Dumping cluster resources"
for ns in $(jq -r '.metadata.name' < ./cluster-dump/ns.json);do kubectl --namespace="${ns}" get all --export -o=json | 
jq '.items[]'| jq 'select(.type!="kubernetes.io/service-account-token")' | jq 'del( .spec.clusterIP, .metadata.uid, .metadata.selfLink, .metadata.resourceVersion, .metadata.creationTimestamp, .metadata.generation, .status, .spec.template.spec.securityContext, .spec.template.spec.dnsPolicy, .spec.template.spec.terminationGracePeriodSeconds, .spec.template.spec.restartPolicy )' 
done >>./cluster-dump/cluster-dump.json
cat ./cluster-dump/cluster-dump.json

echo "to restore run the following: \n"
echo "kubectl create -f cluster-dump/ns.json \n"
echo "kubectl create -f cluster-dump/cluster-dump.json"

