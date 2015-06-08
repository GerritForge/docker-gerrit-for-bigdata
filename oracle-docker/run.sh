#!/usr/bin/env bash

sed -i -E "s/HOST = [^)]+/HOST = $HOSTNAME/g" /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora;

service oracle-xe start;
echo "ORACLE STARTED";
/usr/sbin/sshd -D;
sleep infinity;
