#! /bin/bash
server_ip=$(ifconfig `route -n | grep "^0"|awk '{print $NF}'`|grep -o "addr inet:[0-9\.]*"|cut -d':' -f 2)
if [ "$server_ip"x = ""x ]; then
    server_ip=$(ifconfig `ip  route | grep "default" | awk '{print $NF}'` | grep -o "inet addr:[0-9\.]*" | cut -d":" -f 2)
fi

sudo useradd -p '123ABS' smb

if [ ! -d /opt/samba/share ]; then
    sudo mkdir /opt/samba/share
fi
sudo chmod 777 /opt/samba/share

sed -i 's/[share]/g'  /etc/samba/smb.conf
sed -i 's/  comment = Root Directories/g' /etc/samba/smb.conf
sed -i 's/  browseable = yes/g' /etc/samba/smb.conf
sed -i 's/  path = /opt/samba/share/g' /etc/samba/smb.conf
#sed -i 's/  valid users = smb/g' /etc/samba/smb.conf
sed -i 's/  public = yes/g' /etc/samba/smb.conf
sudo /etc/init.d/smbd restart
if [ $? -ne 0 ]; then
    echo "samba test fail !!!!"
    lava-test-case samba-server fail
fi

echo $! > /tmp/samba-server.pid
lava-send server-ready server_ip=${server_ip}
lava-wait client-done

echo "samba server:"
echo "Server IP: " ${server_ip}
lava-test-case samba-server --shell kill -9 `cat /tmp/samba-server.pid`
