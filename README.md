## CN2 Deployment

The openstack portion of CN2 is deployed as follows. For now, the heat templates and all necessary 
scripts are stored in https://github.com/juniperjoe/cn2-ocp-rhosp-poc. Check out this repo and execute from the top level. Some helpful shell scripts are provided.

### Phase 0 - Control and Compute Node Teardown

```
kubectl delete openstackdeploy -nopenstack default
kubectl delete -f baremetalset.yaml
kubectl delete -f openstackprovisionserver.yaml
kubectl delete -f compute-node3.yaml
kubectl delete -f controlplane.yaml
kubectl delete -f openstacknetconfig.yaml
```

### Phase 1 - Start Base Deployment

Start the deployment. Stop before a required patch explained below.

```
kubectl apply -f openstacknetconfig.yaml
kubectl wait openstacknetconfig -nopenstack openstacknetconfig --for=condition=Provisioned --timeout=-1s
kubectl apply -f controlplane.yaml
kubectl wait openstackcontrolplane -nopenstack overcloud --for=condition=Provisioned --timeout=-1s
kubectl apply -f compute-node3.yaml
```

### Phase 2 - Patch br-osp IP Address

Temporary patch is required for the time being. This needs to be resolved.

From localhost, log into node1, then into node2. Configure IP address on br-osp bridge

```
[localhost] ssh root@10.87.3.146 / c0ntrail123
[node1] ssh 192.168.124.13
[node2] sudo ip addr add 192.168.202.13/24 dev br-osp
```

### Phase 3 - Finish Base Deployment

Continue deployment after patch. At the end of this phase, the control and compute nodes
will be ready for deployment of openstack/contrail playbooks.

```
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
```

### Phase 4 - Deploy Playbooks

Apply openstack/contrail playbooks

```
cd ~/cn2-ocp-rhosp-poc/custom_templates
rm custom-config.tar.gz
tar -cvzf custom-config.tar.gz *
kubectl delete configmap tripleo-tarball-config-3 -n openstack
kubectl create configmap tripleo-tarball-config-3 --from-file=custom-config.tar.gz -n openstack

cd ~/cn2-ocp-rhosp-poc
kubectl delete cm -nopenstack heat-env-config-3
kubectl create configmap -n openstack heat-env-config-3 --from-file=./custom_environment_files/ --dry-run=client -o yaml | kubectl apply -f -

kubectl delete openstackconfiggenerator default -nopenstack
kubectl apply -f openstack-config-generator-2.yaml
sleep 40
kubectl logs -f -nopenstack job/generate-config-default

while [ "$(kubectl get openstackconfiggenerator -nopenstack default -o jsonpath='{.status.configHash}')" == "" ]; do
   sleep 5
   echo "Waiting for openstackconfiggenerator to be ready."
done

export CONFIG_HASH=$(kubectl get openstackconfiggenerator -nopenstack default -o jsonpath='{.status.configHash}')
echo "CONFIG_HASH=$CONFIG_HASH"
sed s/CONFIG_HASH/${CONFIG_HASH}/g deploy_template.tmpl > deploy.yaml

kubectl delete openstackdeploy -nopenstack default

kubectl apply -f deploy.yaml
sleep 5
kubectl logs -f -nopenstack job/deploy-openstack-default
```

### Phase 5 - Verify Deployment

Verify that the deployment was successful by logging into the compute node and controller node.
The contrail-vrouter-agent pod should be up on the compute node. Also, verify the XMPP 
connections. 

Note: the first 4 lines below are a patch that may be required

```
rm -f /run/.containerenv
subscription-manager refresh
sleep 3
dnf -y install mc

yum -y install net-tools
netstat -anp | grep 5269

[root@compute-0 cloud-admin]# netstat -anp | grep 5269
tcp        0      0 172.19.19.150:35369     172.19.19.12:5269       ESTABLISHED 555383/contrail-vro 
tcp        0      0 172.19.19.150:42771     172.19.19.10:5269       ESTABLISHED 555383/contrail-vro 
```


