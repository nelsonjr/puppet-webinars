class infra::require_machine_name {

  if $machine_name == undef {
    fail('Fact "machine_name" has to be defined')
  }

}
