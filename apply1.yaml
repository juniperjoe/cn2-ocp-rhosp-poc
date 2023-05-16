kubectl apply -f openstacknetconfig.yaml
kubectl wait openstacknetconfig -nopenstack openstacknetconfig --for=condition=Provisioned --timeout=-1s
kubectl apply -f controlplane.yaml
kubectl wait openstackcontrolplane -nopenstack overcloud --for=condition=Provisioned --timeout=-1s
kubectl apply -f compute-node3.yaml

