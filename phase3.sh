kubectl apply -f openstackprovisionserver.yaml
kubectl apply -f baremetalset.yaml
while [ "$(kubectl get baremetalhost -nopenshift-machine-api   compute-5a5s12-node3 -o jsonpath='{.status.provisioning.state}')" != "provisioned" ]; do
   sleep 30
   echo "Waiting for baremetalhost to be ready."
done
kubectl cp rhsm-controller.yaml -nopenstack -c openstackclient openstackclient:/home/cloud-admin
kubectl cp rhsm-compute.yaml -nopenstack -c openstackclient openstackclient:/home/cloud-admin
kubectl exec -it -nopenstack openstackclient -c openstackclient -- ansible-playbook -i /home/cloud-admin/ctlplane-ansible-inventory /home/cloud-admin/rhsm-controller.yaml
sleep 60
kubectl exec -it -nopenstack openstackclient -c openstackclient -- ansible-playbook -i /home/cloud-admin/ctlplane-ansible-inventory /home/cloud-admin/rhsm-compute.yaml

