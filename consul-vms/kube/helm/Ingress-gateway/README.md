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





