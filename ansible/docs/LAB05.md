# LAB05 — Ansible Fundamentals (Submission)

## 1. Architecture Overview

**Ansible version (control node):**
```bash
$ ansible --version
ansible [core 2.20.2]
  config file = /Users/philarmonia/Documents/current_course/CBS-02/DevOps/DevOps-Core-Course/ansible/ansible.cfg
  configured module search path = ['/Users/philarmonia/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /opt/homebrew/Cellar/ansible/13.3.0/libexec/lib/python3.14/site-packages/ansible
  ansible collection location = /Users/philarmonia/.ansible/collections:/usr/share/ansible/collections
  executable location = /opt/homebrew/bin/ansible
  python version = 3.14.3 (main, Feb  3 2026, 15:32:20) [Clang 16.0.0 (clang-1600.0.26.6)] (/opt/homebrew/Cellar/ansible/13.3.0/libexec/bin/python)
  jinja version = 3.1.6
  pyyaml version = 6.0.3 (with libyaml v0.2.5)
```

**Target VM:**
- Cloud: AWS
- Public IP: `98.80.214.147`
- OS: Ubuntu (22.04 or 24.04) — paste `lsb_release -a` output:

**Role-based structure (why roles):**
- Roles keep tasks modular, reusable, and easier to test/maintain compared to a single monolithic playbook.

**Project tree (high level):**
- `roles/common` — baseline packages + optional timezone
- `roles/docker` — installs Docker Engine, enables service, docker group, installs `python3-docker`
- `roles/app_deploy` — logs in to Docker Hub via Vault, pulls image, runs container, health checks

## 2. Roles Documentation

### Role: common
**Purpose:** baseline server setup (apt cache + essential tools).
**Variables (defaults):**
- `common_packages` (list)
- `common_set_timezone` (bool)
- `common_timezone` (string)
**Handlers:** none
**Dependencies:** none

### Role: docker
**Purpose:** install Docker Engine from Docker’s official apt repo, enable/start service, add user(s) to docker group.
**Variables (defaults):**
- `docker_users` (list)
- `docker_packages` (list)
**Handlers:**
- `restart docker`
**Dependencies:** none (but pairs well with `common`)

### Role: app_deploy
**Purpose:** deploy container image `s1mphonia/devops-core-app-python` on port 5000 and verify `/health`.
**Variables (defaults):**
- `docker_image`, `docker_image_tag`
- `app_port`, `app_container_name`
- `app_restart_policy`
- `app_env` (dict)
**Handlers:**
- `restart app container`
**Dependencies:** Docker must exist (run provision first)

## 3. Idempotency Demonstration (Provisioning)

Run from `ansible/`:

```bash
ansible-playbook playbooks/provision.yml
```

```text
PLAY [Provision web servers] *****************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************
ok: [aws_vm]

TASK [common : Update apt cache] *************************************************************************************************
ok: [aws_vm]

TASK [common : Install common packages] ******************************************************************************************
ok: [aws_vm]

TASK [common : Set timezone (optional)] ******************************************************************************************
ok: [aws_vm]

TASK [docker : Install prerequisites for Docker repository] **********************************************************************
ok: [aws_vm]

TASK [docker : Ensure /etc/apt/keyrings exists] **********************************************************************************
ok: [aws_vm]

TASK [docker : Remove legacy Docker repo list if present] ************************************************************************
changed: [aws_vm]

TASK [docker : Remove legacy Docker keyring if present] **************************************************************************
ok: [aws_vm]

TASK [docker : Download Docker GPG key (ascii)] **********************************************************************************
ok: [aws_vm]

TASK [docker : Dearmor Docker GPG key into keyring] ******************************************************************************
ok: [aws_vm]

TASK [docker : Add Docker apt repository] ****************************************************************************************
changed: [aws_vm]

TASK [docker : Update apt cache after adding Docker repo] ************************************************************************
changed: [aws_vm]

TASK [docker : Install Docker packages] ******************************************************************************************
changed: [aws_vm]

TASK [docker : Ensure Docker service is enabled and running] *********************************************************************
ok: [aws_vm]

TASK [docker : Add users to docker group] ****************************************************************************************
changed: [aws_vm] => (item=ubuntu)

TASK [docker : Install Python Docker SDK for Ansible docker modules] *************************************************************
ok: [aws_vm]

RUNNING HANDLER [docker : restart docker] ****************************************************************************************
changed: [aws_vm]

PLAY RECAP ***********************************************************************************************************************
aws_vm                     : ok=17   changed=6    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

Run again:

```bash
ansible-playbook playbooks/provision.yml
```

```text
PLAY [Provision web servers] *****************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************
ok: [aws_vm]

TASK [common : Update apt cache] *************************************************************************************************
ok: [aws_vm]

TASK [common : Install common packages] ******************************************************************************************
ok: [aws_vm]

TASK [common : Set timezone (optional)] ******************************************************************************************
ok: [aws_vm]

TASK [docker : Install prerequisites for Docker repository] **********************************************************************
ok: [aws_vm]

TASK [docker : Ensure /etc/apt/keyrings exists] **********************************************************************************
ok: [aws_vm]

TASK [docker : Remove legacy Docker repo list if present] ************************************************************************
changed: [aws_vm]

TASK [docker : Remove legacy Docker keyring if present] **************************************************************************
ok: [aws_vm]

TASK [docker : Download Docker GPG key (ascii)] **********************************************************************************
ok: [aws_vm]

TASK [docker : Dearmor Docker GPG key into keyring] ******************************************************************************
ok: [aws_vm]

TASK [docker : Add Docker apt repository] ****************************************************************************************
changed: [aws_vm]

TASK [docker : Update apt cache after adding Docker repo] ************************************************************************
changed: [aws_vm]

TASK [docker : Install Docker packages] ******************************************************************************************
ok: [aws_vm]

TASK [docker : Ensure Docker service is enabled and running] *********************************************************************
ok: [aws_vm]

TASK [docker : Add users to docker group] ****************************************************************************************
ok: [aws_vm] => (item=ubuntu)

TASK [docker : Install Python Docker SDK for Ansible docker modules] *************************************************************
ok: [aws_vm]

PLAY RECAP ***********************************************************************************************************************
aws_vm                     : ok=16   changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

**Analysis (brief):**
- First run shows many tasks as `changed` because packages/repos/services were configured for the first time.
- Second run should be mostly `ok`, proving idempotency (no unnecessary changes).

## 4. Ansible Vault Usage

**How secrets are stored:**
- Docker Hub credentials are stored in `group_vars/all.yml` encrypted with `ansible-vault`.

**Vault commands used:**
```bash
ansible-vault create group_vars/all.yml
ansible-vault view group_vars/all.yml
```

```text
Vault password: 
dockerhub_username: "s1mphonia"
dockerhub_password: <token>

app_name: devops-core-app-python
docker_image: "s1mphonia/devops-core-app-python"
docker_image_tag: latest
app_port: 5000
app_container_name: "{{ app_name }}"
```

**Password strategy:**
- Use `--ask-vault-pass` or a `.vault_pass` file (chmod 600, add to `.gitignore`).

## 5. Deployment Verification

Deploy:

```bash
ansible-playbook playbooks/deploy.yml --ask-vault-pass
```

Paste terminal output from deploy:

```text
PLAY [Deploy application] ********************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************
ok: [aws_vm]

TASK [app_deploy : Ensure python3-docker is installed (required by docker modules)] **********************************************************************************
ok: [aws_vm]

TASK [app_deploy : Login to Docker Hub (uses vaulted credentials)] ***************************************************************************************************
ok: [aws_vm]

TASK [app_deploy : Pull application image] ***************************************************************************************************************************
ok: [aws_vm]

TASK [app_deploy : Run application container (recreate if needed)] ***************************************************************************************************
changed: [aws_vm]

TASK [app_deploy : Wait for app port to be reachable] ****************************************************************************************************************
ok: [aws_vm]

TASK [app_deploy : Check /health endpoint] ***************************************************************************************************************************
ok: [aws_vm]

TASK [app_deploy : Show health response] *****************************************************************************************************************************
ok: [aws_vm] => {
    "health.content": "{\"status\":\"healthy\",\"timestamp\":\"2026-02-26T20:12:16.584997+00:00\",\"uptime_seconds\":11}\n"
}

RUNNING HANDLER [app_deploy : restart app container] *****************************************************************************************************************
changed: [aws_vm]

PLAY RECAP ***********************************************************************************************************************************************************
aws_vm                     : ok=9    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

Verify container status:

```bash
ansible webservers -a "docker ps"
```

Paste output:

```text
aws_vm | CHANGED | rc=0 >>
CONTAINER ID   IMAGE                                     COMMAND           CREATED              STATUS          PORTS                    NAMES
c1c0be526b78   s1mphonia/devops-core-app-python:latest   "python app.py"   About a minute ago   Up 37 seconds   0.0.0.0:5000->8000/tcp   devops-core-app-python
```

Verify health endpoint:

```bash
curl http://98.80.214.147:5000/health
curl http://98.80.214.147:5000/
```

Paste outputs:

```text
{"status":"healthy","timestamp":"2026-02-26T20:13:24.872887+00:00","uptime_seconds":52}
{"endpoints":[{"description":"Service information","method":"GET","path":"/"},{"description":"Health check","method":"GET","path":"/health"}],"request":{"client_ip":"80.91.223.132","method":"GET","path":"/","user_agent":"curl/8.4.0"},"runtime":{"current_time":"2026-02-26T20:13:31.023096+00:00","timezone":"UTC","uptime_human":"0 minutes","uptime_seconds":58},"service":{"description":"DevOps course info service","framework":"Flask","name":"devops-info-service","version":"1.0.0"},"system":{"architecture":"x86_64","cpu_count":2,"hostname":"c1c0be526b78","platform":"Linux","platform_version":"#7~24.04.1-Ubuntu SMP Thu Jan 22 21:04:49 UTC 2026","python_version":"3.13.12"}}
```

## 6. Key Decisions (2–3 sentences each)

- **Why use roles instead of plain playbooks?**
- **How do roles improve reusability?**
- **What makes a task idempotent?**
- **How do handlers improve efficiency?**
- **Why is Ansible Vault necessary?**

## 7. Challenges (Optional)

- <bullet points>
