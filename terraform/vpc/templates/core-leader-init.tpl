#!/bin/bash

set -x

${init_prefix}

# create a unique hostname
HN_PREFIX="${hostname_prefix}"
INSTANCE_ID="`ec2metadata --instance-id`"
HOSTNAME="$$HN_PREFIX-$$INSTANCE_ID"
hostnamectl set-hostname $$HOSTNAME

# write out bootstrap.sls
cat <<EOT >> ${bootstrap_pillar_file}
# pillar for hostname updates
hostname: $$HOSTNAME

# pillar for consul.service formula
consul:
  datacenter: ${consul_datacenter}
  disable_remote_exec: ${consul_disable_remote_exec}
  secret_key: '${consul_secret_key}'
  master_token: '${consul_master_token}'
  client_token: '${consul_client_token}'
  leader_count: '${leader_count}'
  retry_interval: '3s'

# pillar for nomad.service formula
nomad:
  server: True
  server_count: ${nomad_server_count}
  datacenter: ${nomad_datacenter}
  region: ${nomad_region}
  secret: ${nomad_secret}
  consul:
    token: ${consul_master_token}
EOT

echo "role: leaders" > /etc/salt/grains

echo "${log_prefix} ensure all pieces have the new hostname"
salt-call --local state.sls hostname,salt.minion

${attach_volume}

bash -c "salt-call --local mount.mount /opt/hashistack /dev/xvdf1 mkmnt=True"
salt-call --local mount.set_fstab /opt/hashistack /dev/xvdf1 ext4

#CMD="docker run --detach foobar/foo"
#echo "$CMD" > /etc/rc.local
#$CMD

echo "${log_prefix} restart dnsmasq to be sure it is online"
service dnsmasq restart
echo "${log_prefix} apply the consul.service salt formula to run a leader"
salt-call --local state.sls consul.service --log-level=${log_level}

echo "${log_prefix} apply the nomad salt formula to run a server/leader"
salt-call --local state.sls nomad
salt-call --local state.sls nomad.consul_check_agent --log-level=${log_level}
