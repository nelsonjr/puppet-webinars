class profile::wordpress::migrate($auto_migrate = false) {

  $rsync_target_query = 'facts {
    name = "gce" and certname in resources[certname] {
     type = "Class" and title = "Profile::Wordpress::Migrate::Prep" and certname in nodes[certname] {
       deactivated is null
      }
    }
  }'

  $db_target_query = 'resources {
    type = "Class" and title = "Profile::Wordpress" and certname in resources[certname] {
     type = "Class" and title = "Profile::Wordpress::Migrate::Prep" and certname in nodes[certname] {
       deactivated is null
      }
    }
  }'

  $rsync_target = puppetdb_query($rsync_target_query)[0]['value']['instance']['networkInterfaces'][0]['accessConfigs'][0]['externalIp']
  $db_target    = puppetdb_query($db_target_query)[0]['parameters']

  file { '/root/migrate.sh':
    content => epp('profile/wordpress/migrate.sh.epp', {
      'password' => $db_target['db_password'],
      'host_ip'  => $rsync_target,
      'db_ip'    => $db_target['db_host'],
    }),
    mode    => '0700',
   }

  if $auto_migrate {
    exec { 'automatic migration':
      command => '/root/migrate.sh',
      creates => '/root/migration_completed',
    }
  }
} 
