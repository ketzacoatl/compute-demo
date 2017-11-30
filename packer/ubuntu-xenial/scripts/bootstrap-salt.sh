#!/bin/sh

set -uex
# see http://repo.saltstack.com/#ubuntu for more info
# import the SaltStack repository key
wget -O - https://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest/SALTSTACK-GPG-KEY.pub | apt-key add -

# point apt at the official saltstack repo
echo "deb http://repo.saltstack.com/apt/ubuntu/16.04/amd64/latest xenial main" > /etc/apt/sources.list.d/saltstack.list
# ensure PPAs are active and install the salt minion!
apt-get update
apt-get install -y salt-minion
# disable the service until configured
service salt-minion stop

# the bootstrap formula might need git installed..
apt-get install -y git

# clone our salt formula to bootstrap salt formula
#export BOOTSTRAP_BRANCH="data-ops-eval"
#export BOOTSTRAP_LOG_LEVEL="debug"
wget -O - https://raw.githubusercontent.com/fpco/bootstrap-salt-formula/master/install.sh | sh

# overwrite the empty bootstrap pillar with the user's
mv /tmp/bootstrap-salt-formula-pillar.sls /srv/bootstrap-salt-formula/pillar/bootstrap.sls

# bootstrap salt formula!
salt-call --local                                           \
          --log-level=debug                                 \
          --file-root   /srv/bootstrap-salt-formula/formula \
          --pillar-root /srv/bootstrap-salt-formula/pillar  \
          --config-dir  /srv/bootstrap-salt-formula/conf    \
          state.highstate

# setup pillar for running state.highstate
# the user gave us pillar .sls as uploads, move them into place for salt
mv /tmp/pillar /srv/

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
