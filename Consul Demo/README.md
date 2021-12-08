# consul-policy-example-demo

This is a demo which:

- creates a consul on a minikube,
- creates namespaces (base, team1, team2, team3) within k8s and syncs them to consul
- creates matching roles, policies and tokens for the three team namespaces
- changes the consul so that the team tokens can only see their own namespace and the content within the base namespace

requires minikube installed and a consul license file placed in resources/consul.hclic

To run the demo, just execute the shell scripts after each other, use cleanup.sh to cleanup the environment after the demo.