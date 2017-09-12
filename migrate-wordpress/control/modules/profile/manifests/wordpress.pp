# Class: profile::wordpress
#
# This class contains all site specific configuration for installing Wordpress
# for our demo
#
# Actions:
#   - Setup Wordpress database
#   - Install Wordpress
#   - Enable Apache vhost for Wordpress
#
class profile::wordpress(
  String $db_host = $facts['gce']['instance']['attributes']['database-ip-address'],
  String $root_db_password,
  String $db_password
) {

  # A few extra packages that are required Wordpress to work in MySQL...plus
  # vim
  $required_packages = [
    'vim',
    'wget',
    'php-mysql'
  ]

  package { $required_packages:
    ensure => present,
  }

  # This makes sure we have the correct database clients so we are able to
  # create databases with Puppet, client needs to match server version or
  # things are not likely to work.
  Class { 'profile::wordpress::database::client': before => Mysql::Db['wordpress'] }

  # Handling the database creation using the defined resources type provided to
  # us by the MySQL Puppet module (https://forge.puppet.com/puppetlabs/mysql)
  # instead of using the support that's directly coded into the Wordpress module
  # because its dated.
  mysql::db { 'wordpress':
    user     => 'wp-db',
    password => $db_password,
    host     => '%',
    grant    => 'ALL',
    before   => Class['wordpress'],
  }

  # Wordpress Puppet module (https://forge.puppet.com/hunner/wordpress) that
  # handles the retrieval, unpacking, and configuration of a Wordpress instance.
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

  # Wordpress module sets up a standard user but doesn't manage the home
  # directory.
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

  # Create our wp-user an ssh key that we'll export for later use, using a
  # simple custom fact.
  exec { 'wp_owner_ssh_key':
    command => "ssh-keygen -N '' -f /home/wp-user/.ssh/id_rsa",
    path    => '/bin:/usr/bin',
    user    => 'wp-user',
    creates => '/home/wp-user/.ssh/id_rsa.pub',
    require => File['/home/wp-user/.ssh'],
  }

  # We're running this Wordpress instances with Apache and to manage it we'll
  # use the tried and true Puppet module from Puppet, Inc.
  # (https://forge.puppet.com/puppetlabs/apache)
  class { 'apache':
    default_vhost => false,
    user          => 'wp-user',
    group         => 'wp-group',
    mpm_module    => 'prefork',
  }

  # Enable PHP Apache module, requires us to switch to prefork
  include apache::mod::php
  include apache::mod::prefork

  apache::vhost { 'www.eclipsecorner.org':
    port       => '80',
    docroot    => '/opt/wordpress',
    # Block access for the .git source.
    # We don't like attackers learning about our infrastructure.
    block      => 'scm',
  }

  # This is where Wordpress will be installed, Class['wordpress'] requires
  # this directory implicitly so even though it is down here, it'll happen
  # before Wordpress is installed.
  file { '/opt/wordpress':
    ensure  => directory,
    owner   => 'wp-user',
    group   => 'wp-group',
    mode    => '0775',
    seltype => 'httpd_var_lib_t',
  }

  # These directories aren't created on install but we need it to exist ahead
  # of time so we can copy our source images into it.
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
