# Ensures that the Wordpress server IP was allocated and store the value for use
# by other manifests.
class infra::require_wordpress_ip {

  require infra::wordpress_ip

  if ! $infra::wordpress_ip::address {
    fail("Step 1 for machine ${machine_name} not executed.
          This step requires an allocated IP address for server to continue.")
  }

}
