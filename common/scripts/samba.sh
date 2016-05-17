#! /bin/bash

. ../../distro/common/utils/sys_info.sh

log_file="samba.log"

function install_softwares()
{
    declare -A distro_sofware_dic
    ubuntu_list='smbclint smbfs'
    fedora_list='smb-client smb-common'
    distro_software_dic=([ubuntu]=$ubuntu_list [fedora]=$fedora_list)
    softwares=${distro_software_dic[$distro]}
    . ../../distro/common/utils/install_update_soft.sh "$update_commands" "$install_commands" "$softwares" $log_file $distro
    [ $? -ne 0 ] && echo -1
}

install_softwares
if [ $? -ne 0 ]; then
    echo 'install softwares for samba fail'
    lava-test-case install-software-4-samba --result fail
else
    echo 'install softwares for samba pass'
    lava-test-case install-software-4-samba --result pass
fi
#$install_commands samba smbfs smbclient 
#sudo useradd -p '123ABS' smb

if [ ! -d /opt/samba/share ]; then
    sudo mkdir -p /opt/samba/share
fi
sudo chmod 777 /opt/samba/share

cat >> /etc/samba/smb.conf << EOM
[share]
   comment = Root Directories
   browseable = yes
   writeable = yes
   path = /opt/share
   #valid users = smb
   public = yes
EOM

sudo /etc/init.d/smbd restart
if [ $? -ne 0 ]; then
    echo "samba test fail !!!!"
    lava-test-case samba-server-restart --result fail
else
    echo "samba test succ"
    lava-test-case samba-server-restart --result pass
fi
echo $! > /tmp/samba-server.pid

#### for client visit ####
TEST_CASE="samba-visit-share"

echo "Running samba client "
echo -n "${TEST_CASE}: "
smbclient ${local_ip}/share 2>&1 | tee ${log_file}
echo -n "${TEST_CASE}: "
lava-test-case samba-client --shell [ -z "`grep "Connection refused" samba.log`" ] && true || false
lava-test-case-attach smaba-client ${log_file}
#### client visit ending ####

echo "samba server:"
echo "Server IP: " ${local_ip}
lava-test-case samba-server --shell kill -9 `cat /tmp/samba-server.pid`
