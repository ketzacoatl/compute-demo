#!/bin/sh

set -uex

# install saltstack and clone the bootstrap
# salt formula (to install all salt formula)
#export BOOTSTRAP_BRANCH="data-ops-eval"
#export BOOTSTRAP_LOG_LEVEL="debug"
export BOOTSTRAP_PILLAR_FILE="/tmp/bootstrap-salt-formula-pillar.sls"
wget -O - https://raw.githubusercontent.com/fpco/bootstrap-salt-formula/master/simple-bootstrap.sh | sh

# setup pillar for running state.highstate
# the user gave us pillar .sls as uploads, move them into place for salt
mv /tmp/pillar /srv/
