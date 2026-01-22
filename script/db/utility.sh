#!/bin/bash

#####################################################################
# check
#####################################################################

if ! type psql >/dev/null 2>&1; then
  echo "ERROR: psql command not found" 1>&2
  exit 1
fi

if ! psql -h "${DB_HOST}" -p "${DB_PORT}" -U 'postgres' \
    -c 'select 1' 'postgres' >/dev/null 2>&1; then
  echo "ERROR: cannot access to database (not running ?)" 1>&2
  exit 1
fi

#####################################################################
# function
#####################################################################

function default_user_command() {
  local USER='postgres'
  local COMMAND=$1

  any_user_command "${USER}" "${COMMAND}"
}

function manage_all_user_command() {
  local USER='manage_all_role'
  local COMMAND=$1

  any_user_command "${USER}" "${COMMAND}"
}

function manage_master_user_command() {
  local USER='manage_master_role'
  local COMMAND=$1

  any_user_command "${USER}" "${COMMAND}"
}

function manage_transaction_user_command() {
  local USER='manage_transaction_role'
  local COMMAND=$1

  any_user_command "${USER}" "${COMMAND}"
}

function refer_user_command() {
  local USER='refer_role'
  local COMMAND=$1

  any_user_command "${USER}" "${COMMAND}"
}

function any_user_command() {
  local USER=$1
  local COMMAND=$2

  psql -h "${DB_HOST}" -p "${DB_PORT}" -U "${USER}" \
    -c "${COMMAND}" "${DB_NAME}"
}

function init_state_command() {
  local COMMAND=$1

  psql -h "${DB_HOST}" -p "${DB_PORT}" -U 'postgres' \
    -c "${COMMAND}" 'postgres'
}
