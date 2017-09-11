#!/usr/bin/env bash

if [ -e '/home/wp-user/.ssh/id_rsa.pub' ];then
  echo "wp_user_ssh_pub=$(cat /home/wp-user/.ssh/id_rsa.pub)"
fi
