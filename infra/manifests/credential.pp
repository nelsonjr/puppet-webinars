class infra::credential {

  gauth_credential { 'cred':
    provider => serviceaccount,
    path     => '/opt/admin/my_account.json',
    scopes   => [
      'https://www.googleapis.com/auth/cloud-platform',
      'https://www.googleapis.com/auth/sqlservice.admin',
    ],
  }

}
