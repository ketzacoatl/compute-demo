#!/bin/sh

##
# print out some debug info
#
# don't fail if one of these prints fail
set +e

# all of /srv/* is root only, and not world readable
chown -R root:root /srv
chmod -R o-rwx /srv

echo "minion formula:"
ls -alh /srv/*/* #/srv/*/*/_*
echo "minion configs:"
ls -alh /etc/salt/*
cat /etc/salt/minion.d/*
echo "version check:"
salt-call --version
