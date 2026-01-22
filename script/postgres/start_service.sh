#!/bin/bash
set -u

#####################################################################
# setting
#####################################################################

postgres_ver='17'

bin_dir="/usr/lib/postgresql/${postgres_ver}/bin"
data_dir='/var/lib/postgresql/data'

#####################################################################
# check directory
#####################################################################

if [ ! -e "${bin_dir}" ]; then
  echo "error: binary directory not found <${bin_dir}>" 1>&2
  exit 1
fi

if [ ! -e "${data_dir}" ]; then
  echo "error: data directory not found <${data_dir}>" 1>&2
  exit 1
fi

#####################################################################
# check service
#####################################################################

cur_status=$("${bin_dir}/pg_ctl" -D "${data_dir}" status)

if echo "${cur_status}" | grep -q 'server is running'; then
  echo "info: service has already been running" 1>&2
  exit 0
fi

#####################################################################
# start service
#####################################################################

"${bin_dir}/pg_ctl" -D "${data_dir}" -w -t 60 start
