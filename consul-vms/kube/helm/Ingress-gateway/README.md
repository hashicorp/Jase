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


![image](https://github.com/hashicorp/Jase/assets/81739850/828a7bb7-bf92-4343-8d22-1bcf01eb0e53)





## STEP BY STEP GUIDE on Installing Consul on VM´s with full zero trust and TLS. 
This guide describes the following:
- How top install a secure DC.
- TLS is enabled everywhere
- Default Deny
- Auto Encrypt
### Setup of DC1
