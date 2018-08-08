#!/bin/bash

APT_NET=192.168.0.50
HOSTNAME=bowed-end

sudo apt-get update
sudo apt-get upgrade

sudo apt-get install python-jinja2 python-pip libssl-dev -fy
mkdir ~/.pip

tee ~/.pip/pip.conf <<-'EOF'
[global]
trusted-host =  mirrors.aliyun.com
index-url = https://mirrors.aliyun.com/pypi/simple
EOF

sudo pip install --upgrade pip
sudo pip install ansible
sudo pip install kolla-ansible==4.0.3
sudo pip install python-openstackclient

cp -r /usr/local/share/kolla-ansible/etc_examples/kolla /etc/kolla

sudo mv global.yml /etc/kolla/global.yml -y

sudo mkdir -p /etc/kolla/config/nova

sudo tee /etc/kolla/config/nova/nova-compute.conf <<-'EOF'
[libvirt]
virt_type = qemu
cpu_mode = none
EOF

echo ${APT_NET} ${HOSTNAME} >> /etc/hosts

sudo mv all-in-one /usr/local/share/kolla-ansible/ansible/inventory/all-in-one

kolla-genpwd

sudo kolla-ansible \
-i /usr/local/share/kolla-ansible/ansible/inventory/all-in-one \
bootstrap-servers

sudo tee /etc/docker/daemon.json <<-'EOF'
{
"registry-mirrors":  ["https://ao6wb0ej.mirror.aliyuncs.com"]
}
EOF

sudo systemctl daemon-reload
sudo  service docker restart

sudo kolla-ansible pull

sudo kolla-ansible prechecks \
-i /usr/local/share/kolla-ansible/ansible/inventory/all-in-one

# ironic bugs fix
sudo modprobe configfs
sudo apt-get remove open-iscsi

sudo mkdir -p /etc/kolla/config/ironic

cd /etc/kolla/config/ironic
sudo wget http://otcloud-gateway.bj.intel.com/deployment-img/ironic-agent.kernel 
sudo wget http://otcloud-gateway.bj.intel.com/deployment-img/ironic-agent.initramfs 

sudo mv ironic.conf /etc/kolla/config/ironic.conf

# delpoy openstack
sudo kolla-ansible deploy \
-i /usr/local/share/kolla-ansible/ansible/inventory/all-in-one

sudo kolla-ansible post-deploy
