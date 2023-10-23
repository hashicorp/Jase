![](Files/Consul_Enterprise_Logo_Color_RGB.svg)

**Disclaimer: This setup is for POC purposes and not fit for production**

#   Ingress Gateway instructions Guide


![image](https://github.com/hashicorp/Jase/assets/81739850/f7cd24ef-5e80-4d3c-9f4c-e7ce54038294)

- Update Ingress Gateway Block within helm chart if not already completed

Helm instructions:

```
ingressGateways:
  defaults:
    replicas: 1
    service:
      ports:
      - nodePort: null
        port: 443
      - nodePort: null
        port: 8080
      type: LoadBalancer
  enabled: true
  gateways:
  - name: ingress-gateway

```
save config and upgrade helm chart with new ingress gateway bloxk (if required)

```
helm upgrade --install -f config-dc1.yaml consul hashicorp/consul -n consul --debug 
```

once completed check pods and service have been built

```
kubectl get pods -n consul

kubectl get svc -n consul
```

![image](https://github.com/hashicorp/Jase/assets/81739850/1ae286fe-58fe-4888-b0a9-e2dab915b5c2)




![image](https://github.com/hashicorp/Jase/assets/81739850/82d9b89f-64e3-40c9-a267-66d9283e2ffd)


## STEP BY STEP GUIDE on Installing Ingress Gateway. 
This guide describes the following definitions and services needed :
- Frontend service deployment
- Backend service deployment
- Ingress config.
- service defaults
- service router
- service resolver
- Default Deny as default
- intention
- port-forward ingress-gateway service

  
### Setup steps

Deploy Frontend directory that will provision all the service above apart from the Backend services

```
kubectl apply -f Frontend/

```

![image](https://github.com/hashicorp/Jase/assets/81739850/f202717f-bbb8-4390-9608-6139b3abf4b9)

Frontend service will deploy alongside your other services that you have already deployed.

The frontend service will have 2 services deployed a v1 and v2 to loadbalance the traffic and you will also see that the resolver only against frontend

![image](https://github.com/hashicorp/Jase/assets/81739850/f99b10ab-7425-4cdc-9e6b-43ddbe600f0e)

![image](https://github.com/hashicorp/Jase/assets/81739850/95a5fbc6-1e7e-4a12-9641-98715e945e31)





Ingress gateway will have 1 upstream now deployed inside of it (as you can see above) this was from the ingress configuration file deployment

acess the service ingress gateway and select the upstream tab, you will now see the listening port for that upstream

![image](https://github.com/hashicorp/Jase/assets/81739850/c284640a-c560-4453-90a9-3e5213d71a17)

Deploy Backend directory that will provision the Backend service

```
kubectl apply -f backend/

```

The list of service you will see in the top screenshot of services. Once this has been deployed you can now portforward the ingress gateway service and listening port 8080

```
kubectl port-forward svc/consul-ingress-gateway --namespace consul 8080:8080

```
Open up browser with local port and port 8080

```
127.0.0.1:8080

```
you will now see the 2 different versions of service loadbalance every other request as shown below

### Version 1

![image](https://github.com/hashicorp/Jase/assets/81739850/4f4db51b-d272-41e9-9da8-47b455cddc71)

### Version 2

![image](https://github.com/hashicorp/Jase/assets/81739850/c4c36f9d-4fcc-4e40-903f-e542df9bcbac)

if you delete v1 in Frontend directory you will see it will only stay on v2 😁😁😁😁


```
kubectl delete -f deployment-v1.yaml

```

INGRESS GATEWAY TESTED...............GOOD JOB ALL 😁😁😁😁😁👌...................






