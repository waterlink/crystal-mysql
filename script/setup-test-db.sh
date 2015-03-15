#!/usr/bin/env bash

PARAMS="-u ${MYSQL_USER:-root}"
[[ -z "$MYSQL_PASS" ]] || PARAMS="$PARAMS -P '${MYSQL_PASS}'"
[[ -z "$MYSQL_ASK_PASS" ]] || PARAMS="$PARAMS -p"

mysql $PARAMS -e "create database crystal_mysql_test"
mysql $PARAMS -e "create user 'crystal_mysql'@'localhost'"
mysql $PARAMS -e "grant all on crystal_mysql_test.* to 'crystal_mysql'@'localhost'"
