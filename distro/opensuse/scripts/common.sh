#!/bin/bash

distro="opensuse"
update_commands="zypper -n update "
install_commands="zypper -n install "
restart_service="systemctl restart "
start_service="systemctl start "
status_service="systemctl status "

#sevice_start="service"
local_ip=$(ifconfig `route -n | grep "^0"|awk '{print $NF}'`|grep -o "addr inet:[0-9\.]*"|cut -d':' -f 2)
if [ ${local_ip}x != ""x ]; then
    local_ip=$(ip addr show `ip route | grep "default" | awk '{print $NF}'`| grep -o "inet [0-9\.]*" | cut -d" " -f 2)
fi

