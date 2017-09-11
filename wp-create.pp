#-----
# Credentials

gauth_credential { 'cred':
  provider => serviceaccount,
  path     => '/opt/admin/my_account.json',
  scopes   => [
    'https://www.googleapis.com/auth/cloud-platform',
    'https://www.googleapis.com/auth/sqlservice.admin',
  ],
}

#-----
# Infrastructure

gcompute_region { 'us-central1':
  project    => 'graphite-demo-puppet-webinar1',
  credential => 'cred',
}

gcompute_zone { 'us-central1-c':
  project    => 'graphite-demo-puppet-webinar1',
  credential => 'cred',
}

gcompute_machine_type { 'n1-standard-2':
  zone       => 'us-central1-c',
  project    => 'graphite-demo-puppet-webinar1',
  credential => 'cred',
}

gcompute_network { 'default':
  ensure     => present,
  project    => 'graphite-demo-puppet-webinar1',
  credential => 'cred',
}

#-----
# Resources

if $machine_name == undef {
  fail('Fact "machine_name" has to be defined')
}

gcompute_disk { $machine_name:
  ensure       => present,
  size_gb      => 50,
  source_image => gcompute_image_family('centos-7', 'centos-cloud'),
  zone         => 'us-central1-c',
  project      => 'graphite-demo-puppet-webinar1',
  credential   => 'cred',
}

gcompute_address { $machine_name:
  ensure     => present,
  region     => 'us-central1',
  project    => 'graphite-demo-puppet-webinar1',
  credential => 'cred',
}

gcompute_instance { $machine_name:
  ensure             => present,
  machine_type       => 'n1-standard-2',
  disks              => [
    {
      boot        => true,
      source      => $machine_name,
      auto_delete => true,
    },
  ],
  metadata           => [
    {
      'startup-script-url' =>
        'https://puppet-enterprise:8140/packages/current/install.bash',
    },
  ],
  network_interfaces => [
    {
      network        => 'default',
      access_configs => [
        {
          name   => 'External NAT',
          nat_ip => $machine_name,
          type   => 'ONE_TO_ONE_NAT',
        },
      ],
    },
  ],
  zone               => 'us-central1-c',
  project            => 'graphite-demo-puppet-webinar1',
  credential         => 'cred',
}

#-----
# Dependencies

$legacy_server = '13.59.50.69'
$current_server = $legacy_server

#-----
# Creates the database

gsql_instance { $machine_name:
  ensure           => present,
  database_version => 'MYSQL_5_7',
  settings         => {
    ip_configuration => {
      authorized_networks => [
        {
          name  => 'Admin workstation',
          value => '104.197.210.80/32',
        },
        {
          name  => 'Legacy server',
          value => "${legacy_server}/32",
        },
      ],
    },
    tier             => 'db-n1-standard-1',
  },
  region           => 'us-central1',
  project          => 'graphite-demo-puppet-webinar1',
  credential       => 'cred',
}

gsql_user { 'wordpress':
  ensure     => present,
  password   => 'secret-password',
  host       => '%',
  instance   => $machine_name,
  project    => 'graphite-demo-puppet-webinar1',
  credential => 'cred',
}

#-----
# Creates the DNS records

gdns_managed_zone { 'eclipsecorner-org':
  ensure     => present,
  dns_name   => 'eclipsecorner.org.',
  project    => 'graphite-demo-puppet-webinar1',
  credential => 'cred',
}

gdns_resource_record_set { 'www.eclipsecorner.org.':
  ensure       => present,
  managed_zone => 'eclipsecorner-org',
  type         => 'A',
  target       => $current_server,
  ttl          => 5,
  project      => 'graphite-demo-puppet-webinar1',
  credential   => 'cred',
}
