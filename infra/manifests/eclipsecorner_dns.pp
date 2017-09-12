class infra::eclipsecorner_dns {
  include infra::credential
  include infra::infrastructure
  include infra::wordpress_ip

  include infra::require_machine_name
  include infra::require_wordpress_ip

  warning(">>>>>>>> UPDATE DNS MANIFEST TO AFFECT REAL www RECORD <<<<<<<<")

  gdns_managed_zone { 'eclipsecorner-org':
    ensure     => present,
    dns_name   => 'eclipsecorner.org.',
    project    => 'graphite-demo-puppet-webinar1',
    credential => 'cred',
  }

  gdns_resource_record_set { 'www-test.eclipsecorner.org.':
    ensure       => present,
    managed_zone => 'eclipsecorner-org',
    type         => 'A',
    target       => $infra::wordpress_ip::address,
    ttl          => 5,
    project      => 'graphite-demo-puppet-webinar1',
    credential   => 'cred',
  }
}
