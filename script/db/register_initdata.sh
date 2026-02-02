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
# delete existing record
#####################################################################

manage_all_user_command "
TRUNCATE TABLE master_schema.user_table
restart identity;"

manage_all_user_command "
TRUNCATE TABLE master_schema.relationship_table
restart identity;"

manage_all_user_command "
TRUNCATE TABLE master_schema.give_category_table
restart identity;"

manage_all_user_command "
TRUNCATE TABLE master_schema.use_category_table
restart identity;"

manage_all_user_command "
TRUNCATE TABLE transaction_schema.give_record_table
restart identity;"

manage_all_user_command "
TRUNCATE TABLE transaction_schema.use_record_table
restart identity;"

manage_all_user_command "
TRUNCATE TABLE transaction_schema.use_request_table
restart identity;"

#####################################################################
# main routine
#####################################################################

# ユーザの情報を登録
manage_master_user_command "
INSERT INTO master_schema.user_table 
(user_name, user_login_id, user_login_password, user_favorite, user_especially)
VALUES
('ライオン', 'lion', 'lion', '焼肉', '牛肉'),
('羊', 'sheep', 'sheep', 'ドリンク', '紅茶'),
('豚', 'pig', 'pig', 'ドリンク', '緑茶');"

# 上司・部下の関係を登録
# 例）ライオンは羊の上司
# 例）ライオンは豚の上司
# サンプルなので直接user_idを記載している
manage_master_user_command "
INSERT INTO master_schema.relationship_table
(subordinate_user_id, superior_user_id)
VALUES
(2, 1),
(3, 1);"

# ポイント付与の情報を登録
# 例）経費処理をしたらデフォルトで1ポイントゲット
manage_master_user_command "
INSERT INTO master_schema.give_category_table
(give_category_name, default_give_point)
VALUES
('経費処理',1),
('見積もり',1),
('清掃', 2);"

# ポイント消費の情報を登録
# 例）焼肉したらデフォルトで15ポイント消費
manage_master_user_command "
INSERT INTO master_schema.use_category_table
(use_category_name, default_use_point)
VALUES
('焼肉',15),
('ドリンク', 1),
('1on1時間確保', 1);"

# ポイント付与の情報を登録
# 例）ライオンは羊に2025/01/01 10:00:00に経費請求対応を理由に1ポイント付与
# 例）ライオンは豚に2025/01/02 10:00:00に見積もり対応を理由に1ポイント付与
# 例）ライオンは豚に2025/01/03 10:00:00に清掃対応を理由に2ポイント付与
manage_transaction_user_command "
INSERT INTO transaction_schema.give_record_table
(relationship_id, occur_date, give_category_id, give_point)
VALUES
(1, '2025/01/01 10:00:00', 1, 1),
(2, '2025/01/02 10:00:00', 2, 1),
(2, '2025/01/03 10:00:00', 3, 2);"

# ポイント消費の情報を登録
# 例）羊はライオンに2026/01/01 12:00:00に1ポイントを消費してドリンクをもらう
manage_transaction_user_command "
INSERT INTO transaction_schema.use_record_table
(relationship_id, occur_date, use_record_id, use_point)
VALUES
(1, '2026/01/01 12:00:00', 2, 1);"
