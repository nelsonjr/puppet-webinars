class infra::wordpress_database {

  include infra::credential
  include infra::infrastructure

  include infra::require_machine_name

  # We require the Wordpress server IP to lock SQL down.
  include infra::require_wordpress_ip

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
            name  => 'Current server',
            value => "${infra::wordpress_ip::address}/32",
          },
          {
            name  => 'Legacy server',
            value => "${infra::infrastructure::legacy_server}/32",
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

  # Fetch the IP address of the VM
  $fn_auth = gauth_credential_for_function(
    'serviceaccount', '/opt/admin/my_account.json',
    ['https://www.googleapis.com/auth/cloud-platform']
  )

  $address = gsql_instance_ip($machine_name,
                              'graphite-demo-puppet-webinar1', $fn_auth)
  info("Wordpress database @ ${address}")
}
