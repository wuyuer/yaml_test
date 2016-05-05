#! /bin/bash
server_ip=$(ifconfig `route -n | grep "^0"|awk '{print $NF}'`|grep -o "addr inet:[0-9\.]*"|cut -d':' -f 2)
if [ "$server_ip"x = ""x ]; then
    server_ip=$(ip addr show `ip route | grep "default" | awk '{print $NF}'`| grep -o "inet [0-9\.]*" | cut -d" " -f 2)
fi
. ../../common.sh

sudo useradd -p '123ABS' smb

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
lava-send server-ready server_ip=${server_ip}
lava-wait client-done

echo "samba server:"
echo "Server IP: " ${server_ip}
lava-test-case samba-server --shell kill -9 `cat /tmp/samba-server.pid`
