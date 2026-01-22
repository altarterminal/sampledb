#!/bin/bash
set -u

###########################################################
# usage
###########################################################

# 0. postgresデータベースが稼働していることを確認する（前提条件）
# 1. 直下の"setting"セクションのパラメータを設定する
# 2. 引数なしでこのスクリプトを実行する

###########################################################
# setting
###########################################################

DB_HOST=127.0.0.1
DB_PORT=5432

DB_NAME='sample_db'

###########################################################
# import
###########################################################

THIS_DIR=$(dirname "${BASH_SOURCE[0]}")
. "${THIS_DIR}/utility.sh"

###########################################################
# query
###########################################################

# 上司がライオンであるユーザを一覧化する
refer_user_command "
SELECT u1.user_name FROM
  master_schema.relationship_table as r
  INNER JOIN master_schema.user_table AS u1
  ON r.subordinate_user_id = u1.user_id
  INNER JOIN master_schema.user_table AS u2
  ON r.superior_user_id = u2.user_id
    WHERE u2.user_name = 'ライオン'
"

# ライオンが与えたポイント一覧化する
refer_user_command "
SELECT * FROM transaction_schema.give_point_record_table as gpr
  WHERE gpr.relationship_id IN (
    SELECT relationship_id FROM master_schema.relationship_table as r
      WHERE r.superior_user_id = (
        SELECT user_id FROM master_schema.user_table as u
          WHERE u.user_name = 'ライオン'
      )
  )
"
