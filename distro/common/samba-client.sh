
#!/bin/sh

#set -e
#set -x

TEST_CASE="samba-visit-share"

lava-wait server-ready
server_ip=$(cat /tmp/lava_multi_node_cache.txt | cut -d = -f 2)
echo "Running samba client "
echo -n "${TEST_CASE}: "
smbclient ${server_ip}/share 2>&1 | tee result.log
echo -n "${TEST_CASE}: "
lava-test-case samba-client --shell [ -z "`grep "Connection refused" result.log`" ] && true || false
lava-test-case-attach smaba-client result.log
lava-send client-done
