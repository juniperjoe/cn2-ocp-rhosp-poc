#!/bin/bash

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
source ./prepare_deploy.sh

kubectl delete openstackdeploy -nopenstack default

kubectl apply -f deploy.yaml
sleep 5
kubectl logs -f -nopenstack job/deploy-openstack-default

