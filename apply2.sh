kubectl apply -f openstackprovisionserver.yaml
kubectl apply -f baremetalset.yaml
./getready.sh
kubectl cp rhsm-controller.yaml -nopenstack -c openstackclient openstackclient:/home/cloud-admin
kubectl cp rhsm-compute.yaml -nopenstack -c openstackclient openstackclient:/home/cloud-admin
kubectl exec -it -nopenstack openstackclient -c openstackclient -- ansible-playbook -i /home/cloud-admin/ctlplane-ansible-inventory /home/cloud-admin/rhsm-controller.yaml
kubectl exec -it -nopenstack openstackclient -c openstackclient -- ansible-playbook -i /home/cloud-admin/ctlplane-ansible-inventory /home/cloud-admin/rhsm-compute.yaml

