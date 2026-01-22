#!/bin/bash
set -u

#####################################################################
# setting
#####################################################################

postgres_ver='17'

bin_dir="/usr/lib/postgresql/${postgres_ver}/bin"
data_dir='/var/lib/postgresql/data'

conf_file="${data_dir}/postgresql.conf"
hba_file="${data_dir}/pg_hba.conf"

localhost_ip='127.0.0.1/24'
localnet_ip='10.229.44.128/25'

tmp_file="${TMPDIR:-/tmp}/${0##*/}_tmp"

#####################################################################
# initdb
#####################################################################

if [ -e "${data_dir}" ]; then
  echo "info: data directory has already exist <${data_dir}>" 1>&2
else
  "${bin_dir}/initdb" "${data_dir}"
fi

#####################################################################
# init setting
#####################################################################

cat "${conf_file}" |
  grep -v '^ *listen_addresses *=' |
  grep -v '^ *port *=' |
  sed '$alisten_addresses = '"'*'" |
  sed '$aport = 5432' |
  cat > "${tmp_file}"

cp "${tmp_file}" "${conf_file}"

cat "${hba_file}" |
  grep -v "^ *host all all ${localhost_ip} trust" |
  grep -v "^ *host all all ${localnet_ip} trust" |
  sed '$a'"host all all ${localhost_ip} trust" |
  sed '$a'"host all all ${localnet_ip} trust" |
  cat > "${tmp_file}"

cp "${tmp_file}" "${hba_file}"
