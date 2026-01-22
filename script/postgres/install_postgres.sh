#!/bin/bash
set -eu

#####################################################################
# setting
#####################################################################

gpg_url='https://www.postgresql.org/media/keys/ACCC4CF8.asc'
repo_url='https://apt.postgresql.org/pub/repos/apt'

tmp_gpg_file="${TMPDIR:-/tmp}/${0##*/}_tmp"
gpg_register_file='/etc/apt/keyrings/pgdg.gpg'
list_file='/etc/apt/sources.list.d/pgdg.list'

#####################################################################
# install dependency
#####################################################################

sudo apt update
sudo apt install -y curl ca-certificates gnupg lsb-release

#####################################################################
# prepare gpg
#####################################################################

curl -o "${tmp_gpg_file}" -sS "${gpg_url}"

sudo mkdir -p "$(dirname "${gpg_register_file}")"

sudo gpg --dearmor -o "${gpg_register_file}" "${tmp_gpg_file}"

#####################################################################
# register gpg
#####################################################################

sudo mkdir -p "$(dirname "${list_file}")"

printf 'deb [signed-by=%s] %s %s-pgdg main\n' \
  "${gpg_register_file}" "${repo_url}" "$(lsb_release -cs)" |
  sudo tee "${list_file}" >/dev/null

rm "${tmp_gpg_file}"

#####################################################################
# install postgres
#####################################################################

sudo apt update
sudo apt install -y postgresql-17
