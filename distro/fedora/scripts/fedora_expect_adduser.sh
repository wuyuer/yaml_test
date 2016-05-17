#!/usr/bin/expect

set timeout 600
set USERNAME [lindex $argv 0]

spawn passwd $USERNMAE
expect "New password:"
send "$mysql_password\r"
expect "Retype new password:"
send "$mysql_password\r"
expect eof

