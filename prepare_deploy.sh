while [ "$(kubectl get openstackconfiggenerator -nopenstack default -o jsonpath='{.status.configHash}')" == "" ]; do
   sleep 5
   echo "Waiting for openstackconfiggenerator to be ready."
done

export CONFIG_HASH=$(kubectl get openstackconfiggenerator -nopenstack default -o jsonpath='{.status.configHash}')
echo "CONFIG_HASH=$CONFIG_HASH"
sed s/CONFIG_HASH/${CONFIG_HASH}/g deploy_template.tmpl > deploy.yaml
