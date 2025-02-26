#!/bin/sh

home_dir="/home/piku"
user="piku"
group="www-data"

# Add piku user if does not exist
id -u ${user} >/dev/null 2>&1 || useradd -g "${group}" "${user}"

# Create directory with permissions
install -m 0700 -o "${user}" -g "${group}" -d "${home_dir}"

# Copy authorized_keys from root
install -m 0600 -o "${user}" -g "${group}" "$(realpath ~root)/.ssh/authorized_keys" "/tmp/root_authorized_keys"

# Install packages
apt update
apt install bc git build-essential libpcre3-dev zlib1g-dev python python3 python3-pip python3-click python3-dev python3-virtualenv python3-setuptools nginx incron acl uwsgi-core uwsgi-plugin-python3 nodeenv

# Create uwgsi symlink
(uwgsi_symlink=/usr/local/bin/uwsgi-piku && [ -f ${uwgsi_symlink} ] || ln -s $(which uwsgi) ${uwgsi_symlink})

# Install uwsgi dist script
(source=https://raw.githubusercontent.com/piku/piku/master/uwsgi-piku.dist
dest=/etc/init.d/uwsgi-piku
[ -f ${dest} ] || curl ${source} -o ${dest} && chmod 0700 ${dest})

# Install uwsgi-piku dist script
[ -f /etc/rc2.d/S01uwsgi-piku ] || update-rc.d uwsgi-piku defaults

# Install uwsgi-piku systemd script
(source=https://raw.githubusercontent.com/piku/piku/master/uwsgi-piku.service
dest=/etc/systemd/system/uwsgi-piku.service
[ -f ${dest} ] || curl ${source} -o ${dest} && chmod 0600 ${dest})

su - piku <<"EOF"
  # Fetch piku.py script
  source=https://raw.githubusercontent.com/angordeyev/piku/master/piku.py
  dest=~/piku.py
  [ -f ${dest} ] || curl ${source} -o ${dest} && chmod 0700 ${dest}

  # Run piku setup
  [ -f ~/.piku ] || python3 ~/piku.py setup

  # Ask piku to use SSH keys
  [ -f ~/.ssh/authorized_keys ] ||
  cat /tmp/root_authorized_keys | while read line
  do
    echo ${line} > /tmp/id_rsa.pub && ~/piku.py setup:ssh /tmp/id_rsa.pub && rm /tmp/id_rsa.pub
  done
  rm /tmp/root_authorized_keys

  # Install acme.sh, change acme.sh CA to Let's Encrypt and enable automatic upgrades
  curl https://get.acme.sh | sh
  ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt --auto-upgrade
EOF

# Enable and start uwsgi-piku service
systemctl enable --now uwsgi-piku

# Get nginx default config and restart nginx
curl https://raw.githubusercontent.com/piku/piku/master/nginx.default.dist > /etc/nginx/sites-available/default
systemctl restart nginx

# Get incron config an restart incron service
curl https://raw.githubusercontent.com/piku/piku/master/incron.dist > /etc/incron.d/piku
systemctl restart incron
