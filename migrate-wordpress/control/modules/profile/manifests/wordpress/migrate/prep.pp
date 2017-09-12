# Class: profile::wordpress::migrate::prep
#
# Queries and places into the wp-user's the SSH public keys published by source
#
# Actions:
#   - Looks up the "wp_user_ssh_pub" value
#   - Puts discovered key(s) into the correct place
#
class profile::wordpress::migrate::prep {

  # Our source machine needs to log into our target as the "wp-user" so it
  # can rsync images.
  #
  # Query will return all the "wp_user_ssh_pub" facts.
  $source_keys_query = 'facts[value] { name = "wp_user_ssh_pub" }'

  # Run query previously defined against PuppetDB and return the value found
  $source_keys = puppetdb_query($source_keys_query).map |$key| { $key['value'] }

  # Place the discovered value into authorized_keys file.
  file { '/home/wp-user/.ssh/authorized_keys':
    ensure   => file,
    content  => $source_keys.sort.join("\n"),
    owner    => 'wp-user',
  }
}
