class infra::infrastructure {

  require infra::credential

  $legacy_server = '13.59.50.69'

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
}
