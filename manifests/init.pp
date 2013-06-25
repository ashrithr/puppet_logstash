class logstash($role) inherits logstash::params {

  if ! ($role in [ 'indexer', 'shipper' ]) {
    fail("\"${role}\" is not a valid ensure parameter value")
  }

  class { 'logstash::package': } ->
  class { 'logstash::config': } ~>
  class { 'logstash::service': }

  Class['logstash']
}