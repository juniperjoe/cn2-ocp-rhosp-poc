kubectl delete openstackdeploy -nopenstack default

kubectl apply -f deploy.yaml
sleep 5
kubectl logs -f -nopenstack job/deploy-openstack-default

