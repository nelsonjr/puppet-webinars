# Allocates a static IP address for the Wordpress server instance.
class infra::wordpress_ip {
  require infra::credential
  require infra::infrastructure

  require infra::require_machine_name

  gcompute_address { $machine_name:
    ensure     => present,
    region     => 'us-central1',
    project    => 'graphite-demo-puppet-webinar1',
    credential => 'cred',
  }

  # Fetch the IP address of the VM
  $fn_auth = gauth_credential_for_function(
    'serviceaccount', '/opt/admin/my_account.json',
    ['https://www.googleapis.com/auth/cloud-platform']
  )

  $address = gcompute_address_ip($machine_name, 'us-central1',
                                 'graphite-demo-puppet-webinar1', $fn_auth)
  info("Wordpress server @ ${address}")
}
