class logstash($role, $indexer = undef) inherits logstash::params {

  if ! ($role in [ 'indexer', 'shipper' ]) {
    fail("\"${role}\" is not a valid ensure parameter value")
  }

  if $role == 'indexer' {
    notice('installing role logstash indexer (server)')
    #requires java module
    class { 'java': } ->
    class { 'logstash::redis': } ->
    class { 'logstash::elasticsearch': } ->
    class { 'logstash::kibana': } ->
    class { 'logstash::package': } ->
    class { 'logstash::config':
      role => $role,
      indexer => $indexer
    } ~>
    class { 'logstash::service': }
  } else {
    notice('installing role logstash shipper (agent)')
    #shipper requires a indexer(hostname|ip) to send events to
    if $indexer == undef {
      fail("\"${role}\" requires hostname|ip of indexer")
    }
    #requires java module
    class { 'java': } ->
    class { 'logstash::package': } ->
    class { 'logstash::config':
      role => $role,
      indexer => $indexer
    } ~>
    class { 'logstash::service': }
  }

}