# LAB04 — Infrastructure as Code (Local VM Alternative)

## 1. Cloud Provider & Infrastructure
I used an existing VDS (public VPS) instead of provisioning a new VM in a cloud provider.
This follows the "Local VM Alternative" option from the lab.

- VM type: VDS (already provisioned by hosting provider)
- Public IP: 46.8.64.5
- SSH access: key-based, no password
- Planned usage for Lab 5: YES (keep this VM for Ansible)

## 2. VM Setup Proof
### OS
```
root@server-xx5cre:~# uname -a
Linux server-xx5cre 6.8.0-35-generic #35-Ubuntu SMP PREEMPT_DYNAMIC Mon May 20 15:51:52 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux
root@server-xx5cre:~# lsb_release -a || cat /etc/os-release
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 24.04 LTS
Release:	24.04
Codename:	noble
```

### Network / IP
```
root@server-xx5cre:~# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq state UP group default qlen 1000
    link/ether fa:16:3e:3b:58:97 brd ff:ff:ff:ff:ff:ff
    altname enp0s3
    altname ens3
    inet 46.8.64.5/24 metric 100 brd 46.8.64.255 scope global dynamic eth0
       valid_lft 34686sec preferred_lft 34686sec
root@server-xx5cre:~# 
```
### SSH access proof
```
philarmonia@MacBook-Air-Aleksei-2 ~ % ssh root@46.8.64.5 "whoami && hostname && uptime"
root
server-xx5cre
 20:16:15 up  8:31,  2 users,  load average: 0.00, 0.00, 0.00
philarmonia@MacBook-Air-Aleksei-2 ~ % 
```
## 3. Firewall / Required Ports
```
root@server-xx5cre:~# ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), deny (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere                  
80/tcp                     ALLOW IN    Anywhere                  
5000/tcp                   ALLOW IN    Anywhere                  
22/tcp (v6)                ALLOW IN    Anywhere (v6)             
80/tcp (v6)                ALLOW IN    Anywhere (v6)             
5000/tcp (v6)              ALLOW IN    Anywhere (v6)             
```

## 4. Terraform Implementation
Not applicable in this variant because the VM was already created (Local VM Alternative).
Instead, infrastructure readiness is ensured by configuring SSH access and firewall rules on the VDS.
## 5. Pulumi Implementation
Not applicable in this variant because no cloud infrastructure was created/destroyed.
The existing VDS is used as the target VM.
## 6. Terraform vs Pulumi Comparison
Terraform and Pulumi are IaC tools for provisioning resources via cloud APIs.
In this lab variant, provisioning was not performed because an existing VM was used.
Main conceptual difference:
Terraform: declarative HCL approach
Pulumi: imperative approach using real programming languages
## 7. Lab 5 Preparation & Cleanup
Keeping VM for Lab 5: YES
VM details: 46.8.64.5, SSH key-based access
Cleanup: no cloud resources were created, so no destroy step was needed
