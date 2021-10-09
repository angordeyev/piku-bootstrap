#!/bin/sh

home_dir="/home/piku"
user="piku"
group="www-data"
ssh_user="root"

# add piku user if does not exist
id -u ${user} >/dev/null 2>&1 || useradd -g "${group}" "${user}"

# create directory with permissions
install -m 0700 -o "${user}" -g "${group}" -d "${home_dir}" 

# Copy authorized_keys from root
install -m 0600 -o "${user}" -g "${group}" "$(realpath ~root)/.ssh/authorized_keys" "/tmp/root_authorized_keys" 

# Install packages
apt install bc git build-essential libpcre3-dev zlib1g-dev python python3 python3-pip python3-click python3-dev python3-virtualenv python3-setuptools nginx incron acl uwsgi-core uwsgi-plugin-python3 nodeenv

# Create uwgsi symlink
test -f /usr/local/bin/uwsgi-piku || ln -s $(which uwsgi) /usr/local/bin/uwsgi-piku

# Install uwsgi dist script
test -f /etc/init.d/uwsgi-piku ||
  curl https://raw.githubusercontent.com/piku/piku/master/uwsgi-piku.dist -o /etc/init.d/uwsgi-piku &&
  chmod 0700

# Install uwsgi-piku dist script
test -f /etc/rc2.d/S01uwsgi-piku || update-rc.d uwsgi-piku defaults

# Install uwsgi-piku systemd script
test -f /etc/systemd/system/uwsgi-piku.service ||
  curl https://raw.githubusercontent.com/piku/piku/master/uwsgi-piku.service -o /etc/systemd/system/uwsgi-piku.service &&
  chmod 0600
