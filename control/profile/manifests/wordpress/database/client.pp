class profile::wordpress::database::client {

  include mysql::client
  package { 'mysql-server': ensure => present }

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
