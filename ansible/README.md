# Lab05 — Ansible Fundamentals (Generated Project)

## Quickstart

From `ansible/`:

```bash
# Install collections
ansible-galaxy collection install -r requirements.yml

# Test connectivity (static inventory)
ansible all -m ping

# Provision
ansible-playbook playbooks/provision.yml

# Create Vault (use template as a guide)
#   ansible-vault create group_vars/all.yml
# or copy example then encrypt:
#   cp group_vars/all.yml.example group_vars/all.yml
#   ansible-vault encrypt group_vars/all.yml

# Deploy
ansible-playbook playbooks/deploy.yml --ask-vault-pass
```

## Bonus — AWS Dynamic Inventory

1) Ensure AWS creds are available (env vars, AWS CLI profile, or instance role)
2) Edit `inventory/aws_ec2.yml` region/filter as needed
3) Run:

```bash
ansible-inventory -i inventory/aws_ec2.yml --graph
ansible -i inventory/aws_ec2.yml all -m ping
```
