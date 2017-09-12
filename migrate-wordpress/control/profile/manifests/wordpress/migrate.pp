# Class: profile::wordpress::migrate
#
# Builds script that does image and database migration.  Can be enabled
# to either just put the script in place to be ran later or it can also
# run it for you.
#
# Actions:
#   - Look up information about target system
#   - Generate our migration script
#   - Optionally run migration task
#
class profile::wordpress::migrate(Boolean $auto_migrate = false) {

  # Wordpress puts pictures on disks so we need to query PuppetDB for the IP
  # address of the target instance.
  #
  # Query will return the "gce" fact from the host that is classified with
  # Class['profile::wordpress::migrate::prep'] and has not been deactivated
  # in PuppetDB.
  $rsync_target_query = 'facts {
    name = "gce" and certname in resources[certname] {
     type = "Class" and title = "Profile::Wordpress::Migrate::Prep" and certname in nodes[certname] {
       deactivated is null
      }
    }
  }'

  # Wordpress puts everything else, besides pictures in a database so that has
  # to be synced too.  In this specific demo we are migrating from RDS to
  # CloudSQL, both of which have IP addresses that we are unable to query for
  # in this specific implementation but luckily we can also just simply query
  # this IP again from our target instance by looking up the actual Class
  # resource used to classify the host.
  #
  # Query will return a Class resource and it's parameter values as of last
  # Puppet run that has a title equal to "Profile::Wordpress", that was
  # classified with Class['profile::wordpress::migrate::prep'], and has not been
  # deactivated in PuppetDB.
  $db_target_query = 'resources {
    type = "Class" and title = "Profile::Wordpress" and certname in resources[certname] {
     type = "Class" and title = "Profile::Wordpress::Migrate::Prep" and certname in nodes[certname] {
       deactivated is null
      }
    }
  }'

  # Runs the rsync query defined earlier against PuppetDB and then drills down
  # to return the GCE instance's publicly accessible IP address.
  $rsync_target = puppetdb_query($rsync_target_query)[0]['value']['instance']['networkInterfaces'][0]['accessConfigs'][0]['externalIp']

  # Runs the db query defined earlier against PuppetDB and then drills down to
  # return the Class resource's parameter list we can use them later.
  $db_target = puppetdb_query($db_target_query)[0]['parameters']['

  # A very simple  epp template that builds a bash script that is used to
  # migrate our database and image data.
  file { '/root/migrate.sh':
    content => epp('profile/wordpress/migrate.sh.epp', {
      'password' => $db_target['db_password'],
      'host_ip'  => $rsync_target,
      'db_ip'    => $db_target['db_host'],
    }),
    mode    => '0700',
  }

  # What runs the migration script automatically if one chooses to do so.  Will
  # only run script if its never been ran successfully.
  if $auto_migrate {
    exec { 'automatic migration':
      command => '/root/migrate.sh',
      creates => '/root/migration_completed',
    }
  }
} 
