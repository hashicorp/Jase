# cluster-peering-failover-demo

DIRECTORY INDEX.

Peering of DCs

Helm chart in the DC1 directory and the config files are all in DC1/01-AP-default-default-failover/countingapp

Helm chart in the DC2 directory and the config files are all in DC2/01-AP-default-default-failover/countingapp

DC1 configuration -----> DC1/

DC2 configuration -----> DC2/

Admin Partition on client clusters

Helm chart in the DC1 directory and the config files are all in DC1/02-AP-diffAP-failover/countingapp

Helm chart in the DC2 directory and the config files are all in DC2/02-AP-diffAP-failover/countingapp

DC1 configuration -----> DC1

DC2 configuration -----> DC2/Tenant-1/

DC3 configuration -----> DC3/Teanant-2/


This demo will showcase the ability to failover services between two Consul datacenters (dc1 and dc2) that have been connected via Cluster peering. 
We will deploy a counting app where a dashboard service will connect to the upstream counting service. Both services will reside on dc1.

We will have another instance of the counting service running on dc2. We will similate a failure of the counting service on dc1 by taking down the whole counting service deployment. 

We will then observe how the dashboard will failover to the counting service residing on dc2.

# Pre-reqs

1. You have two Kubernetes clusters available. In this demo example, we will use Azure Kubernetes Service (AKS) but it can be applied to other K8s clusters.


![image](https://user-images.githubusercontent.com/81739850/221880958-1a9170f5-13d4-463a-afdd-141ca191e173.png)



    Note: 
    - If using AKS, you can use the Kubenet CNI or the Azure CNI. The Consul control plane and data plane will use Load Balancers (via Consul mesh gateways)to communicate between Consul datacenters.
    - Since Load Balancers are used on both control plane and data plane, each datacenter can reside on different networks (VNETS, VPCs) or even different clouds (AWS, Azure GCP, private, etc). No direct network connections (ie peering connections) are required. 
    
2. Add or update your hashicorp helm repo:

```
helm repo add hashicorp https://helm.releases.hashicorp.com
```
or
```
helm repo update hashicorp
```

  
# Deploy Consul on first Kubernetes cluster (dc1).

1 If required there is a Terraform code to deploy a cluster ---> DC1/DC1-K8cluster

2 You can run terraform plan and deploy within the directory to build a cluster will take several minutes

Run the following command to retrieve the access credentials for your cluster and automatically configure kubectl.

```aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)```


You can then run the command kubectl cluster-info to verify you are connected to your Kubernetes cluster:

3. Set environemetal variables for kubernetes cluster dc1 and dc2 (Optional)

```
export dc1=<your-kubernetes context-for-dc1>
export dc2=<your-kubernetes context-for-dc2>
export VERSION=1.0.0
```

4. Set context and deploy Consul on dc1

```
kubectl config use-context $dc1

create consul namespace

```
kubectl create namespace consul                                
```

deploy license file into the consul namespace as shown below
``` 
cd DC1/01-AP-default-default-failover/

```
kubectl create secret generic consul-ent-license --namespace consul --from-literal=key="$consul.hclic"

helm install $dc1 hashicorp/consul --version $VERSION --values config-dc1.yaml                                  
```

5. Confirm Consul deployed sucessfully

```
kubectl get pods --context $dc1
NAME                                               READY   STATUS    RESTARTS   AGE

dc1-consul-connect-injector-6694d44877-jvp4s       1/1     Running   0          2m
dc1-consul-mesh-gateway-747c58b75c-s68n7           2/2     Running   0          2m
dc1-consul-server-0                                1/1     Running   0          2m
dc1-consul-webhook-cert-manager-669bb6d774-sb5lz   1/1     Running   0          2m
```  
Note: Run ```kubectl get crd``` and make sure that exportedservices.consul.hashicorp.com, peeringacceptors.consul.hashicorp.com, and peeringdialers.consul.hashicorp.com  exist.    
If not, you need to upgrade your helm deployment:  
    
```
helm upgrade $dc1 hashicorp/consul  --version $VERSION --values config-dc1.yaml
```
cd DC1/01-AP-default-default-failover/countingapp

6. Deploy both dashboard and counting service on dc1
```
files located in DC1/01-AP-default-default-failover/countingapp/
kubectl apply -f dashboard.yaml --context $dc1
kubectl apply -f counting.yaml --context $dc1
```
![image](https://user-images.githubusercontent.com/81739850/221881212-5bc9696b-1bb9-44ed-8ca7-3ab5b28c4406.png)



7. Using your browser, check the dashboard UI and confirm the number displayed is incrementing. 
   You can get the dashboard UI's EXTERNAL IP address with command below. Make sure to append port :9002 to the browser URL.  
```   
kubectl get service dashboard --context $dc1
```

Example: 
```
kubectl get service dashboard --context $dc1
NAME        TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)          AGE
dashboard   LoadBalancer   10.0.179.160   40.88.218.67  9002:32696/TCP   22s
```

![image](https://user-images.githubusercontent.com/81739850/221881398-042c9425-217a-4684-a16d-3e1872d1aea0.png)



# Deploy Consul on second Kubernetes cluster (dc2).


8. Set context and deploy Consul on dc2 ----> Terraform files to build a cluser can be found in DC2/02-AP-diffAP-failover/DC2-K8cluster/

Run the following command to retrieve the access credentials for your cluster and automatically configure kubectl.

```aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)```

You can then run the command kubectl cluster-info to verify you are connected to your Kubernetes cluster:


install license also into the consul namespace

create consul namespace

```
kubectl create namespace consul                                
```

deploy license file into the consul namespace as shown below

```
kubectl create secret generic consul-ent-license --namespace consul --from-literal=key="$consul.hclic"                               
```

kubectl config use-context $dc2

```
helm install $dc2 hashicorp/consul --version $VERSION --values config-dc2.yaml --set global.datacenter=dc2                              
```

Note: Run 

```
kubectl get crd                         
```

and make sure that exportedservices.consul.hashicorp.com, peeringacceptors.consul.hashicorp.com, and peeringdialers.consul.hashicorp.com  exist.    
If not, you need to upgrade your helm deployment:  

```
helm upgrade $dc2 hashicorp/consul  --version $VERSION --values config-dc2.yaml
```

9. Deploy counting service on dc2. This will be the failover service instance.

files can be located in DC2/01-AP-default-default-failover/countingapp/

```
kubectl apply -f counting.yaml --context $dc2
```
# Create cluster peering connection

You can establish the peering connections using the Consul UI or using Kubernetes CRDs. The steps using the UI are extremely easy and straight forward so we will focus on using the Kubernetes CRDs in this section.

10.  If your Consul clusters are on different non-routable networks (no VPC/VPN peering), then you will need to set the Consul servers (control plane) to use mesh gateways to request/accept peering connection. Just apply the meshgw.yaml file on both Kubernetes cluster. 

If you try to establish a peer and get the following error below you will need to deploy the mesh gateways

```
kubectl apply -f meshgw.yaml --context $dc1
kubectl apply -f meshgw.yaml --context $dc2
```

![image](https://user-images.githubusercontent.com/81739850/223142210-03470b91-a419-455f-ae30-a2eaffe1f4fb.png)

You can either use the UI or configuration to setup peering, UI pretty straightforwad to follow

**If you prefer to use the UI to establish the peered connection, the general steps are:**
  - Log onto Consul UI for dc1, navigate to the Peers side tab on the left hand side.
  - Click on **Add peer connection***
  - Enter a name you want to represent the peer that you are connecting to. 
  - Click **Generate token**
  - Copy the newly created token.
  - Log onto Consul UI for dc2, navigate to the Peers side tab on the left hand side.
  - Click on **Add peer connection***
  - Click on **Establish peering**
  - Enter a name you want to represent the peer that you are connecting to.
  - Paste the token and click **Add peer**
  - Your peering connection should be established.


**To establish the peered connection using Kubernetes CRDs, the steps are:**


11. Create Peering Acceptor on dc1 using the provided acceptor-on-dc1-for-dc2.yaml file.
Note: This step will establish dc1 as the Acceptor.
```
kubectl apply -f  acceptor-on-dc1-for-dc2.yaml --context $dc1
```

12. Notice this will create a CRD called peeringacceptors.
```
kubectl get peeringacceptors --context $dc1
NAME   SYNCED   LAST SYNCED   AGE
dc2    True     2m46s         2m47s
```

Notice a secret called peering-token-dc2 is created.

All files located in DC1/countingapp/
```
kubectl get secrets --context $dc1
```

13. Copy peering-token-dc2 from dc1 to dc2.
```
kubectl get secret peering-token-dc2 --context $dc1 -o yaml | kubectl apply --context $dc2 -f -
```

14. Create Peering Dialer on dc2 using the provided dialer-dc2.yaml file.  

Note: This step will establish dc2 as the Dialer and will connect Consul on dc2 to Consul on dc1 using the peering-token.
```
kubectl apply -f  dialer-dc2.yaml --context $dc2
```

15. Export counting service from dc2 to dc1.

![image](https://user-images.githubusercontent.com/81739850/223142441-eb83fd5c-4ec7-4ee6-b832-12412b96d50e.png)


```
kubectl apply -f exportedsvc-counting.yaml --context $dc2
```


16. Apply service-resolver file on dc1. This service-resolver.yaml file will tell Consul on dc1 how to handle failovers if the counting service fails locally. 

Note: Make sure the name of the peer in the service-resolver file matches the name to gave for each peer when you established peering (either in the UI or using CRD acceptor and dialer files).

```
kubectl apply -f service-resolver.yaml --context $dc1
```

17. If you have deny-all intentions set or if ACL's are enabled (which means deny-all intentions are enabled), set intentions using intention.yaml file.  

Note: The UI on Consul version 1.14 does not yet recognize peers for Intention creation. Therefore apply intentions using the CLI, API, or CRDs.

```
kubectl apply -f intentions.yaml --context $dc2
```


![image](https://user-images.githubusercontent.com/81739850/223142747-3a8c5bf8-3b6e-48fa-b420-a2046b1def5f.png)



18. Apply the proxy-defaults on both datacenters to ensure data plane traffic goes via local mesh gateways 
```
kubectl apply -f proxydefaults.yaml --context $dc1
kubectl apply -f proxydefaults.yaml --context $dc2
```

19. Delete the counting service on dc1
```
kubectl delete -f counting.yaml --context $dc1
```

20. Observe the dashboard service on your browser. You should notice that the counter has restarted since the dashboard is connecting to different counting service instance.


**This is your current configuration:**  

![image](https://user-images.githubusercontent.com/81739850/223142917-85385b47-b3fa-4474-86dc-19af4d204ef2.png)

21. Bring counting service on dc1 back up.
```
kubectl apply -f counting.yaml --context $dc1
```
![image](https://user-images.githubusercontent.com/81739850/221921950-3a5b5d38-496c-4ead-92c2-7d044a9623c3.png)


22. Observe the dashboard service on your browser. Notice the the dashboard URL shows the counter has restarted again since it automatically fails back to the original service on dc1.


# (Optional) Deploy Consul (dc3) on EKS Cluster and peer between dc1 as dc3.

![image](https://user-images.githubusercontent.com/81739850/221881568-a6f11dc6-dacf-4f7b-9c8e-c570ebe822eb.png)



This portion is optional if you want to failover to AWS Elastic Kubernetes Service (EKS).   
We will create a peering connection between dc1 and dc3 (on EKS) and failover the counting service to dc3.
This portion assumes you already have an Elastic Kubernetes Service (EKS) cluster deployed on AWS.  


1. Connect your local terminal to your EKS cluster.

Terraform files can be located DC3/DC3-K8cluster to build a cluster

```
aws eks --region <your-aws-region> update-kubeconfig --name <your-eks-cluster-name>
```

2. Set environment variable for your dc3 context.  
   Note: You can find your EKS context using ```kubectl config get-contexts```

```
export dc3=<your EKS cluster context>
```

3. Set context and deploy Consul **dc3** onto your EKS cluster.

```
kubectl config use-context $dc3
``` 
```
helm install $dc3 hashicorp/consul --version $VERSION --values apservice-dc3.yaml.yaml --set global.datacenter=dc3
```
  

Note: Run ```kubectl get crd``` and make sure that exportedservices.consul.hashicorp.com, peeringacceptors.consul.hashicorp.com, and peeringdialers.consul.hashicorp.com  exist.  
	
	If not, you need to upgrade your helm deployment:    
	
	```helm upgrade $dc3 hashicorp/consul --version $VERSION --values apservice-dc3.yaml.yaml```

5. A

```
kubectl apply -f meshgw.yaml --context $dc1
```


5. Establish Peering connection between dc1 and dc3. This time, we can use the Consul UI.

  - Log onto Consul UI for dc1, navigate to the Peers side tab on the left hand side.
  - Click on **Add peer connection***
  - Enter a name you want to represent the peer that you are connecting to (ex: dc3). 
  - Click **Generate token**
  - Copy the newly created token.
  - Log onto Consul UI for dc3, navigate to the Peers side tab on the left hand side.
  - Click on **Add peer connection***
  - Click on **Establish peering**
  - Enter a name you want to represent the peer that you are connecting to (ex: dc1).
  - Paste the token and click **Add peer**
  - Your peering connection should be established.

**Peering Connection is how established between dc1 and dc3**

5. Configure Consul to use mesh gateway to establish the cluster peering.

```
kubectl apply -f meshgw.yaml --context $dc3
```

7. Deploy counting service on dc3.
```
kubectl apply -f counting.yaml --context $dc3
```
8. Export counting services from dc3 to dc1 using the same exportedsvc-backend.yaml file. This will allow the the counting service to be reachable by the dashboard service in dc1
```
kubectl apply -f exportedsvc-counting.yaml --context $dc3
```

9. Edit the service-resolver.yaml file by adding ```- peer: 'dc3'``` as one of the targets. 


It should look like below. Make sure the name of the peer in the service-resolver file matches the name to gave for each peer when you established peering (either in the UI or using CRD acceptor and dialer files).
```
apiVersion: consul.hashicorp.com/v1alpha1
kind: ServiceResolver
metadata:
  name: counting
spec:
  connectTimeout: 15s
  failover:
    '*':
      targets:
        - peer: 'dc2'
        - peer: 'dc3'
```

10. Apply the file to dc1
```
kubectl apply -f service-resolver.yaml --context $dc1
```

	
11. If you have deny-all intentions set or if ACL's are enabled (which means deny-all intentions are enabled), set intentions using intention.yaml file.
```
kubectl apply -f intentions.yaml --context $dc3
```

12. Now let's test the failover by failing the counting service on both dc1 and dc2.
```
kubectl delete -f counting.yaml --context $dc1
kubectl delete -f counting.yaml --context $dc2
```

13. Back on your browser, check the dashboard UI to see the counter has reset and is running.


cluster-client-connectivity & failover-demo
This demo will showcase the ability to connect a client kubernetes cluster into DC1 and failover services between two Consul clusters (default and partition1) that have been connected via consuld ataplane. 

# Deploy Consul on client Kubernetes cluster to connect to kubernetes server cluster (dc1).

1 If required there is a Terraform code to deploy a cluster ---> /DC3-K8cluster

2 You can run terraform plan and deploy within the directory to build a cluster will take several minutes

cd /DC2/02-AP-diffAP-failover

On DC2 create namespace and enterprise license into the consul namespace first

create consul namespace

```
kubectl create namespace consul                                
```

deploy license file into the consul namespace as shown below

``` 
kubectl create secret generic consul-ent-license --namespace consul --from-literal=key="$consul.hclic"

```
Switch to DC1 contect 

3. Copy the server certificate to the non-default partition cluster running your workloads

```
kubectl get secret --namespace consul consul-ca-cert -o yaml | \
kubectl --context arn:aws:eks:us-east-2:711129375688:cluster/<cluster name> apply --namespace consul -f -
```

4. Copy the server key to the non-default partition cluster running your workloads.

```
kubectl get secret --namespace consul consul-ca-key -o yaml | \
kubectl --context arn:aws:eks:us-east-2:711129375688:cluster/<cluster name> apply --namespace consul -f -
```
5. If ACLs were enabled in the server configuration values file, copy the token to the non-default partition cluster running your workloads.

```
kubectl get secret --namespace consul consul-partitions-acl-token -o yaml | \
kubectl --context arn:aws:eks:us-east-2:711129375688:cluster/<cluster name>  apply --namespace consul -f -

```

6. Find expose server in DC1 to establish connection from client cluster

```
kubectl get svc -n consul # on DC1

NAME                             TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)
consul-consul-expose-servers     LoadBalancer   172.20.230.215   a1fecfc8ccdd74b37b5273d7da904e79-1244336522.us-east-2.elb.amazonaws.com   8501:31424/TCP,8301:30094/TCP,8300:31439/TCP,8502:31755/TCP

```

7. find kubernetes master on the client side kubernetes cluster, place the master aputput into the k8sAuthMethodHost: 


```
kubectl cluster-info 

Kubernetes master is running at https://6FA8E20A2D3D90DC7DFC6B39B761BE52.sk1.us-east-2.eks.amazonaws.com
CoreDNS is running at https://6FA8E20A2D3D90DC7DFC6B39B761BE52.sk1.us-east-2.eks.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

```
```
helm install -f config.yaml consul hashicorp/apservice-dc3.yaml -n consul --debug

kubectl get pods -n consul

NAME                                 READY   STATUS      RESTARTS   AGE
consul-consul-partition-init-zzmsz   0/1     Completed   0          3h52m

```
 
