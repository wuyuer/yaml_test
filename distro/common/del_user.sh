#!/bin/bash

function del_user()
{
    USERNAME=$1
    userdel -r  $USERNAME
    if [ ! -d /home/$USERNAME ]; then
        echo "del user $USERNAME success"
        lava-test-case del-user-in-$DISTRO --result pass
    else
        echo "del user $USERNAME fail"
        lava-test-case del-user-in-$DISTRO --result fail
    fi
}

USERNAME="testing"
del_user $USERNAME
