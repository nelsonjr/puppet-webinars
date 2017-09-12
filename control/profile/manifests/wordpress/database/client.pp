# Class: profile::wordpress::database::client
#
# Sets up the MySQL client
#
# Actions:
#   - Make sure MySQL client is installed
#   - Install MySQL server because Puppet needs it
#   - Doesn't actually setup the server
#   - Put a my.cnf in place so we can remotely manage RDS/CloudSQL
#
class profile::wordpress::database::client {

  include mysql::client
  package { 'mysql-server': ensure => present }

  # An epp template that'll enable us to connect to remote database as the
  # root/admin user
  file { '/root/.my.cnf':
    content => epp('profile/wordpress/my.cnf.epp', {
      'host'     => $profile::wordpress::db_host,
      'password' => $profile::wordpress::root_db_password,
      'cloud'    => $facts['virtual']
    }),
    mode    => '0600',
    before  => Class['wordpress'],
  }
}
