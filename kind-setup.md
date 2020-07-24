# Setup [Knative](https://knative.dev) on [Kind](https://kind.sigs.k8s.io/) (Kubernetes In Docker)

These instructions are heavily drawn from https://github.com/csantanapr/knative-kind/

>Updated and verified on 2020/09/04 with:
>- Knative version 0.17.2
>- Kind version 0.8.1
>- Kubernetes version 1.19.0


## Create cluster with Kind

1. Install [kind](https://kind.sigs.k8s.io/docs/user/quick-start/) Linux, MacOS, or Windows. You can verify version with
    ```bash
    kind --version
    ```
1. A kind cluster manifest file [clusterconfig.yaml](./kind/clusterconfig.yaml) is already provided, you can customize it. We are exposing port `80` on the host to be later used by the Knative Kourier ingress. To use a different version of kubernetes check the image digest to use from the kind [release page](https://github.com/kubernetes-sigs/kind/releases)
    ```yaml
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    nodes:
    - role: control-plane
      image: kindest/node:v1.19.0@sha256:3b0289b2d1bab2cb9108645a006939d2f447a10ad2bb21919c332d06b548bbc6
      extraPortMappings:
      - containerPort: 31080 # expose port 31380 of the node to port 80 on the host, later to be use by kourier ingress
        hostPort: 80
    ```
1. Create and start your cluster, we specify the config file above
    ```
    kind create cluster --name knative --config kind/clusterconfig.yaml
    ```
1. Verify the versions of the client `kubectl` and the cluster api-server, and that you can connect to your cluster.
    ```bash
    kubectl cluster-info --context kind-knative
    ```

## Install Knative Serving

1. Select the version of Knative Serving to install
    ```bash
    export KNATIVE_VERSION="0.17.2"
    ```
1. Install Knative Serving in namespace `knative-serving`
    ```bash
    kubectl apply -f https://github.com/knative/serving/releases/download/v$KNATIVE_VERSION/serving-crds.yaml

    kubectl apply -f https://github.com/knative/serving/releases/download/v$KNATIVE_VERSION/serving-core.yaml

    kubectl wait deployment --all --timeout=-1s --for=condition=Available -n knative-serving
    ```
1. Select the version of Knative Net Kurier to install
    ```bash
    export KNATIVE_NET_KOURIER_VERSION="0.17.0"
    ```

1. Install Knative Layer kourier in namespace `kourier-system`
    ```bash
    kubectl apply -f https://github.com/knative/net-kourier/releases/download/v$KNATIVE_NET_KOURIER_VERSION/kourier.yaml

    kubectl wait deployment --all --timeout=-1s --for=condition=Available -n kourier-system

    # deployment for net-kourier gets deployed to namespace knative-serving
    kubectl wait deployment --all --timeout=-1s --for=condition=Available -n knative-serving
    ```
1. Set the environment variable `EXTERNAL_IP` to External IP Address of the Worker Node
    ```bash
    EXTERNAL_IP="127.0.0.1"
    ```
2. Set the environment variable `KNATIVE_DOMAIN` as the DNS domain using `nip.io`
    ```bash
    KNATIVE_DOMAIN="$EXTERNAL_IP.nip.io"
    echo KNATIVE_DOMAIN=$KNATIVE_DOMAIN
    ```
    Double check DNS is resolving
    ```bash
    dig $KNATIVE_DOMAIN
    ```
1. Configure DNS for Knative Serving
    ```bash
    kubectl patch configmap -n knative-serving config-domain -p "{\"data\": {\"$KNATIVE_DOMAIN\": \"\"}}"
    ```
1. Configure Kourier to listen for http port 80 on the node
    ```bash
    cat <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Service
    metadata:
      name: kourier-ingress
      namespace: kourier-system
      labels:
        networking.knative.dev/ingress-provider: kourier
    spec:
      type: NodePort
      selector:
        app: 3scale-kourier-gateway
      ports:
        - name: http2
          nodePort: 31080
          port: 80
          targetPort: 8080
    EOF
    ```
1. Configure Knative to use Kourier
    ```bash
    kubectl patch configmap/config-network \
      --namespace knative-serving \
      --type merge \
      --patch '{"data":{"ingress.class":"kourier.ingress.networking.knative.dev"}}'
    ```
1. Verify that Knative is Installed properly all pods should be in `Running` state and our `kourier-ingress` service configured.
    ```bash
    kubectl get pods -n knative-serving
    kubectl get pods -n kourier-system
    kubectl get svc  -n kourier-system kourier-ingress
    ```

## Install Knative Eventing

1. Select the version of Knative Eventing to install
    ```bash
    export KNATIVE_VERSION="v0.17.2"
    ```
1. Install Knative Eventing in namespace `knative-eventing`
    ```bash
    kubectl apply --filename https://github.com/knative/eventing/releases/download/$KNATIVE_VERSION/eventing-crds.yaml

    kubectl apply --filename https://github.com/knative/eventing/releases/download/$KNATIVE_VERSION/eventing-core.yaml
    ```
1. Install a default in-memory Channel
    ```bash
    kubectl apply --filename https://github.com/knative/eventing/releases/download/$KNATIVE_VERSION/in-memory-channel.yaml
    ```
1. Install a Broker
    ```bash
    kubectl apply --filename https://github.com/knative/eventing/releases/download/$KNATIVE_VERSION/mt-channel-broker.yaml
    ```
1. Monitor the Knative Eventing components until each shows a `STATUS` of `Running`.
    ```bash
    kubectl get pods --namespace knative-eventing
    ```

### Delete Cluster
When you have finished, you can delete the cluster `knative`.

```
kind delete cluster --name knative
```
