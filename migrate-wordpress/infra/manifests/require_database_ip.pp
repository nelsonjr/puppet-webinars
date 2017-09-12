# Ensures that the Wordpress SQL instance is allocated and store the IP address
# for use by other manifests.
class infra::require_database_ip {

  require infra::wordpress_database

  if ! $infra::wordpress_database::address {
    fail("Step 2 for machine ${machine_name} not executed.
          This step requires a running Cloud SQL instance to continue.")
  }

}
