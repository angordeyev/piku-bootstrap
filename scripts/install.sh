#!/bin/sh

home_dir="/home/piku"
user="piku"
group="www-data"
ssh_user="root"

# add piku user if does not exist
id -u ${user} &>/dev/null || useradd -g "${group}" "${user}" 

# create directory with permissions
install -m 0700 -o "${user}" -g "${group}" -d "${home_dir}" 

# Copy authorized_keys from root
install -m 0600 -o "${user}" -g "${group}" "$(realpath ~root)/.ssh/authorized_keys" "/tmp/root_authorized_keys" 
