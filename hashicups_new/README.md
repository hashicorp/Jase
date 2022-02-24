SE Getting Hashicups Up and running locally using K8s
In the following walk through you will create an environment to run HashiCups locally on your machine. The initial form of this doc is created for linux/macos users. WSL users should still be fine but may have to tweak a couple things here or there.

NOTE This is deploying HashiCups and Consul in a non-transparent mode.

Pre-Reqs
Install Docker
Install Helm
A local Kubernetes cluster. Below are some popular options.
Mikube
kind
k3s
Getting Started
Start your local k8s cluster. This may be kind, minikube, k3s, or any other prefered flavor.

Deploy Consul through Helm

helm install -f helm/consul-values.yaml consul hashicorp/consul --version "0.34.1" --wait
Deploy HashiCups. Assumption is that you are in the local-k8s-consul-deployment/ folder.

kubectl apply -f k8s/
Expose the HashiCups UI

kubectl port-forward deploy/frontend 8080:80
Visit http://localhost:8080

Visit Consul UI (Optional)
Expose the Consul UI
kubectl port-forward pods/consul-server-0 8500:8500
Visit http://localhost:8500
Clean-up
Remove all HashiCups resources
kubectl delete -f k8s/
Remove all Consul resources
helm delete consul
Terminate you local kubernetes cluster.
