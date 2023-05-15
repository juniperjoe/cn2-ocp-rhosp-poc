while [ "$(kubectl get baremetalhost -nopenshift-machine-api   compute-5a5s12-node3 -o jsonpath='{.status.provisioning.state}')" != "provisioned" ]; do
   sleep 5
   echo "Waiting for openstackclient to be ready."
done

