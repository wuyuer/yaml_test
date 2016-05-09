#!/bin/bash

USERNAME="testing"

function add_user()
{
/usr/bin/expect << EOF
set timeout 60

spawn adduser $USERNAME
expect "password:"
send "${USERNAME}\r"
expect "password:"
send "${USERNAME}\r"
expect "Full Name"
send "\r"
expect "Room Number"
send "\r"
expect "Work Phone"
send "\r"
expect "Home Phone"
send "\r"
expect "Other"
send "\r"
expect "information correct?"
send "Y\r"
expect eof
EOF
}

add_user
if [ $? -ne 0 ]; then
    echo "add user $USERNAME fail\n"
    lava-test-case add-user-in-$DISTRO --result fail
else
    echo "add user $USERNAME success\n"
    lava-test-case add-user-in-$DISTRO --result pass
fi

