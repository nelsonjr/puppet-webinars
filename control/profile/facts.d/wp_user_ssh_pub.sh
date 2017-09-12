#!/usr/bin/env bash

# Super simple external fact written in bash.  If it detects the presence
# of a SSH public key for the "wp-user", it makes it available to Puppet
# as the "wp_user_ssh_pub" fact.
#
# https://docs.puppet.com/facter/3.8/custom_facts.html#external-facts

if [ -e '/home/wp-user/.ssh/id_rsa.pub' ];then
  echo "wp_user_ssh_pub=$(cat /home/wp-user/.ssh/id_rsa.pub)"
fi
