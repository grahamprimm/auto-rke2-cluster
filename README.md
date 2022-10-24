# Monotone Therapist

Infrastructure as Code (IaC) project.
Takes output yml from JIRA and generates infrastructure using golang microservices, ansible, and terraform


## Steps

1. Build NFS Server and Load Balancer through terraform

2. Build RKE Servers 

3. Build RKE Agents

4. Deploy K8s services