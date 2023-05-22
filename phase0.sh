kubectl delete openstackdeploy -nopenstack default
kubectl delete -f baremetalset.yaml
kubectl delete -f openstackprovisionserver.yaml
kubectl delete -f compute-node3.yaml
kubectl delete -f controlplane.yaml
kubectl delete -f openstacknetconfig.yaml

