#! /bin/bash

. ../../distro/common/utils/sys_info.sh

$install_commands samba smbfs smbclient 
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
    lava-test-case samba-server-restart fail
else
    echo "samba test succ"
    lava-test-case samba-server-restart pass
fi
echo $! > /tmp/samba-server.pid

#### for client visit ####
TEST_CASE="samba-visit-share"

echo "Running samba client "
echo -n "${TEST_CASE}: "
smbclient ${local_ip}/share 2>&1 | tee result.log
echo -n "${TEST_CASE}: "
lava-test-case samba-client --shell [ -z "`grep "Connection refused" result.log`" ] && true || false
lava-test-case-attach smaba-client result.log
#### client visit ending ####

echo "samba server:"
echo "Server IP: " ${local_ip}
lava-test-case samba-server --shell kill -9 `cat /tmp/samba-server.pid`
