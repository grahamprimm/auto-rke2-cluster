[rke2_servers]
%{ for ip in servers ~}
${ip}
%{ endfor ~}
[rke2_agents]
%{ for ip in agents ~}
${ip}
%{ endfor ~}
[rke2_lb]
%{ for ip in lb ~}
${ip} hostname=${lb_hostname}
%{ endfor ~}

[rke2_cluster:children]
rke2_servers
rke2_agents