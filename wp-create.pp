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
