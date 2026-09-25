Content-Type: multipart/mixed; boundary="==BOUNDARY=="
MIME-Version: 1.0
    
--==BOUNDARY==
Content-Type: text/cloud-config; charset="us-ascii"
    
#cloud-config
cloud_final_modules:
- [scripts-user, always]
    
--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash

echo "###########################################################"
echo "################# USER DATA SCRIPT RUNNING ################"
echo "###########################################################"

echo ""

echo "###########################################################"
echo "################### INSTALLING ANSIBLE ####################"
echo "###########################################################"

sudo apt update -y
sudo apt install ansible -y

echo "###########################################################"
echo "################### ANSIBLE INSTALLED #####################"
echo "###########################################################"

echo "CREATING ANSIBLE FILES"

cd home/ubuntu

mkdir inventory

touch key-for-ec2-connection

sudo chmod 777 key-for-ec2-connection

cat << 'EOF' > inventory/production_servers.yaml
backend_servers:
  hosts:
    <server_IP_address>:
      ansible_user: ubuntu
      ansible_ssh_private_key_file: key-for-ec2-connection
EOF

sudo chmod 777 inventory/production_servers.yaml


cat << 'EOF' > ansible.cfg
[defaults]

host_key_checking = False

inventory = inventory/production_servers.yaml
EOF

sudo chmod 777 ansible.cfg


cat << 'EOF' > custom_facts.fact
#!/bin/bash

linux_kernel_version=$(uname -r)

cat << 'EOF_LINUX_KERNEL_VERSION'
{
    "LINUX_KERNEL_VERSION": "$linux_kernel_version"
}
EOF_LINUX_KERNEL_VERSION
EOF

sudo chmod 777 custom_facts.fact


cat << 'EOF' > playbook.yaml
- name: First cloud play
  hosts: backend_servers             # must match in the inventory
  tasks:
    - name: Ping server
      ansible.builtin.ping:

    - name: Print builtin variables
      ansible.builtin.debug:
        msg: {
          "ansible_check_mode": "{{ ansible_check_mode }}",
          "ansible_diff_mode": "{{ ansible_diff_mode }}",
          "ansible_version": "{{ ansible_version['full'] }}",
          "inventory_dir": "{{ inventory_dir }}",
          "inventory_file": "{{ inventory_file }}",
          "inventory_hostname": "{{ inventory_hostname }}",
          "playbook_dir": "{{ playbook_dir }}"
        }

    - name: Print managed node facts
      ansible.builtin.debug:
        # var: ansible_facts
        # var: ansible_facts["distribution"]
        msg: {
          "dns": "{{ ansible_facts['dns'] }}",
          "os_name": "{{ ansible_facts['distribution'] }}",
          "os_version": "{{ ansible_facts['distribution_version'] }}",
          "python_version": "{{ ansible_facts['python_version'] }}",
          "selinux": "{{ ansible_facts['selinux'] }}",
        }


- name: Create facts.d directory and copy custom facts file
  hosts: backend_servers             # must match in the inventory
  become: true
  tasks:
    - name: Create facts.d directory
      ansible.builtin.file:
        path: /etc/ansible/facts.d
        state: directory          # ensure this is a directory
        mode: '0777'              # sets directory permissions
        owner: ubuntu             # optional: sets directory owner
        group: ubuntu             # optional: sets directory group

    - name: Copying custom facts file
      ansible.builtin.copy:
        src: custom_facts.fact
        dest: /etc/ansible/facts.d
        mode: '0777'               # set file permissions
        owner: ubuntu              # optional: sets file owner
        group: ubuntu              # optional: sets file group


- name: Use custom_facts.fact file to get custom facts
  hosts: backend_servers             # must match in the inventory
  tasks:
    - name: Get custom facts
      ansible.builtin.setup:
        filter:
          - 'ansible_local*'


- name: Install and run Apache Web Server
  hosts: backend_servers             # must match in the inventory
  tasks:
    - name: Install Apache on Debian/Ubuntu
      ansible.builtin.apt:
        name: apache2
        state: latest
        update_cache: true
      when: ansible_os_family == "Debian"

    - name: Install Apache on RHEL/CentOS
      ansible.builtin.yum:
        name: httpd
        state: latest
      when: ansible_os_family == "RedHat"

    - name: Enable and start Apache Web Server
      ansible.builtin.service:
        name: "{{ 'apache2' if ansible_os_family == 'Debian' else 'httpd' }}"
        enabled: yes
        state: started
EOF

sudo chmod 777 playbook.yaml

echo "###########################################################"
echo "############### USER DATA SCRIPT FINISHED #################"
echo "###########################################################"