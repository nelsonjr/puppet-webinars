class profile::wordpress::migrate::prep {

  $source_keys_query = 'facts { name = "wp_user_ssh_pub" }'

  $source_keys = any2array(puppetdb_query($source_keys_query)[0]['value'])

  file { '/home/wp-user/.ssh/authroized_keys':
    ensure   => file,
    content  => $source_keys.sort.join("\n"),
    owner    => 'wp-user',
  }
}
