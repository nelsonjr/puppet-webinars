class profile::wordpress(
  $db_host,
  $root_db_password,
  $db_password
) {

  Class { 'profile::wordpress::database::client': before => Class['wordpress'] }

  $required_packages = [
      'vim',
      'wget',
      'php-mysql'
  ]
  
  package { $required_packages:
    ensure => present,
  }

  mysql::db { 'wordpress':
    user     => 'wp-db',
    password => $db_password,
    host     => '%',
    grant    => 'ALL',
    before   => Class['wordpress'],
  } 
  class { 'wordpress':
    wp_owner       => 'wp-user',
    wp_group       => 'wp-group',
    db_name        => 'wordpress',
    db_user        => 'wp-db',
    db_password    => $db_password,
    db_host        => $db_host,
    create_db_user => false,
    create_db      => false,
    version        => '4.8.1',
    require        => Package[$required_packages],
  }

  file { '/home/wp-user':
    ensure  => directory,
    owner   => 'wp-user',
    mode    => '0700',
    require => Class['wordpress'],
  }
  file { '/home/wp-user/.ssh':
    ensure  => directory,
    owner   => 'wp-user',
    mode    => '0700',
  }
  exec { 'wp_owner_ssh_key':
    command => "ssh-keygen -N '' -f /home/wp-user/.ssh/id_rsa",
    path    => '/bin:/usr/bin',
    user    => 'wp-user',
    creates => '/home/wp-user/.ssh/id_rsa.pub',
    require => File['/home/wp-user/.ssh'],
  }
  
  class { 'apache':
    default_vhost => false,
    user          => 'wp-user',
    group         => 'wp-group',
    mpm_module    => 'prefork',
  }
  
  include apache::mod::php
  include apache::mod::prefork

  apache::vhost { 'www.eclipsecorner.org':
    port       => '80',
    docroot    => '/opt/wordpress',
    # Block access for the .git source.
    # We don't like attackers learning about our infrastructure.
    block      => 'scm',
  }

  file { '/opt/wordpress':
    ensure  => directory,
    owner   => 'wp-user',
    group   => 'wp-group',
    mode    => '0775',
    seltype => 'httpd_var_lib_t',
  }
  
  file { '/opt/wordpress/wp-content':
    ensure  => directory,
    owner   => 'wp-user',
    group   => 'wp-group',
    mode    => '0775',
    seltype => 'httpd_var_lib_t',
  }
  
  file { '/opt/wordpress/wp-content/uploads':
    ensure  => directory,
    owner   => 'wp-user',
    group   => 'wp-group',
    mode    => '0775',
    seltype => 'httpd_var_lib_t',
  }
}
