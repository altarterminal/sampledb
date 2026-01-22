#!/bin/bash
set -u

#####################################################################
# usage
#####################################################################

# 0. postgresデータベースが稼働していることを確認する（前提条件）
# 1. 直下の"setting"セクションのパラメータを設定する
# 2. 引数なしでこのスクリプトを実行する

#####################################################################
# setting
#####################################################################

DB_HOST=127.0.0.1
DB_PORT=5432

DB_NAME='sample_db'

#####################################################################
# import
#####################################################################

THIS_DIR=$(dirname "${BASH_SOURCE[0]}")
. "${THIS_DIR}/utility.sh"

#####################################################################
# create user
#####################################################################

# データベースのロール（ユーザ）は以下の4種類を作成
#   - manage_all_role データベースの所有者（全権限あり）
#   - manage_master_role マスターテーブルの更新が可能
#   - manage_transaction_role トランザクションテーブルの更新が可能
#   - refer_role テーブルの参照が可能
# ※すべてのロールはすべてのテーブルを参照可能としている

init_state_command 'CREATE ROLE manage_all_role with LOGIN CREATEDB;'
init_state_command 'CREATE ROLE manage_master_role with LOGIN;'
init_state_command 'CREATE ROLE manage_transaction_role with LOGIN;'
init_state_command 'CREATE ROLE refer_role with LOGIN;'

#####################################################################
# delete exisitng database
#####################################################################

init_state_command "DROP DATABASE ${DB_NAME};"

#####################################################################
# create database and schema
#####################################################################

init_state_command "CREATE DATABASE ${DB_NAME} OWNER manage_all_role;"

manage_all_user_command 'CREATE SCHEMA master_schema;'
manage_all_user_command 'CREATE SCHEMA transaction_schema;'

manage_all_user_command '
GRANT USAGE ON SCHEMA master_schema To manage_master_role;'
manage_all_user_command '
GRANT USAGE ON SCHEMA master_schema To refer_role;'
manage_all_user_command '
GRANT USAGE ON SCHEMA transaction_schema To manage_transaction_role;'
manage_all_user_command '
GRANT USAGE ON SCHEMA transaction_schema To refer_role;'

#####################################################################
# create master table
#####################################################################

manage_all_user_command '
CREATE TABLE master_schema.user_table(
  user_id SERIAL,
  user_name TEXT,
  user_favorite TEXT,
  user_especially TEXT
);'

manage_all_user_command '
CREATE TABLE master_schema.relationship_table(
  relationship_id SERIAL,
  subordinate_user_id INTEGER,
  superior_user_id INTEGER
);'

manage_all_user_command '
CREATE TABLE master_schema.give_point_table(
  give_point_id SERIAL,
  give_category TEXT,
  default_give_point INTEGER
);'

manage_all_user_command '
CREATE TABLE master_schema.use_point_table(
  use_point_id SERIAL,
  use_category TEXT,
  default_use_point INTEGER
);'

#####################################################################
# create transaction table
#####################################################################

manage_all_user_command '
CREATE TABLE transaction_schema.give_point_record_table(
  give_point_record_id SERIAL,
  relationship_id INTEGER,
  occur_date TIMESTAMP,
  give_point_id INTEGER,
  give_point INTEGER
);'

manage_all_user_command '
CREATE TABLE transaction_schema.use_point_record_table(
  use_point_record_id SERIAL,
  relationship_id INTEGER,
  occur_date TIMESTAMP,
  use_point_id INTEGER,
  use_point INTEGER
);'

#####################################################################
# grant access to table
#####################################################################

manage_all_user_command '
GRANT SELECT,INSERT,UPDATE ON ALL TABLES IN SCHEMA master_schema To manage_master_role;'
manage_all_user_command '
GRANT SELECT,INSERT,UPDATE ON ALL TABLES IN SCHEMA transaction_schema To manage_transaction_role;'
manage_all_user_command '
GRANT SELECT ON ALL TABLES IN SCHEMA master_schema To refer_role;'
manage_all_user_command '
GRANT SELECT ON ALL TABLES IN SCHEMA transaction_schema To refer_role;'

#####################################################################
# grant access to sequence
#####################################################################

manage_all_user_command '
GRANT USAGE ON SEQUENCE
master_schema.user_table_user_id_seq To manage_master_role;'

manage_all_user_command '
GRANT USAGE ON SEQUENCE
master_schema.relationship_table_relationship_id_seq To manage_master_role;'

manage_all_user_command '
GRANT USAGE ON SEQUENCE
master_schema.give_point_table_give_point_id_seq To manage_master_role;'

manage_all_user_command '
GRANT USAGE ON SEQUENCE
master_schema.use_point_table_use_point_id_seq To manage_master_role;'

manage_all_user_command '
GRANT USAGE ON SEQUENCE
transaction_schema.give_point_record_table_give_point_record_id_seq To manage_transaction_role;'

manage_all_user_command '
GRANT USAGE ON SEQUENCE
transaction_schema.use_point_record_table_use_point_record_id_seq To manage_transaction_role;'
