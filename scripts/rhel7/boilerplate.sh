#!/usr/bin/env bash

set -o pipefail
set -o nounset
set -o errexit

source /etc/packer/files/functions.sh

# wait for cloud-init to finish
wait_for_cloudinit

# upgrade the operating system
yum update -y && yum autoremove -y

# enable repositories
yum-config-manager --enable rhel-7-server-rhui-rpms
yum-config-manager --enable rhel-7-server-rhui-rh-common-rpms
yum-config-manager --enable rhel-7-server-rhui-extras-rpms

# install dependencies
yum install -y ca-certificates curl yum-utils audit audit-libs parted unzip redhat-lsb-core

curl -sL -o /usr/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod +x /usr/bin/jq

# enable audit log
systemctl enable auditd && systemctl start auditd

# enable the /etc/environment
touch /etc/environment

# install aws cli
install_awscliv2

# install ssm agent
install_ssmagent

echo "ensure secondary disk is mounted to proper locations"
systemctl stop postfix tuned rsyslog crond irqbalance polkit chronyd NetworkManager

partition_disks /dev/nvme1n1

reboot
