class infra::wordpress_instance {

  include infra::credential
  include infra::infrastructure
  include infra::wordpress_ip

  include infra::require_wordpress_ip
  include infra::require_database_ip

  gcompute_disk { $machine_name:
    ensure       => present,
    size_gb      => 50,
    source_image => gcompute_image_family('centos-7', 'centos-cloud'),
    zone         => 'us-central1-c',
    project      => 'graphite-demo-puppet-webinar1',
    credential   => 'cred',
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
        'startup-script-url'  => 
          'https://puppet-enterprise:8140/packages/current/install.bash',
        'database-ip-address' => $infra::wordpress_database::address,
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

}
