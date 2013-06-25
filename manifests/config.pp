class logstash::config {
  # File defaults
  File {
    owner => $logstash::params::logstash_user,
    group => $logstash::params::logstash_group
  }

  # Manage the single config dir
  file { "${logstash::configdir}/conf.d":
    ensure  => directory,
    mode    => '0640',
    purge   => true,
    recurse => true,
    notify  => Service['logstash']
  }

  $tmp_dir = "${logstash::params::installpath}/tmp"

  # Create the tmp dir
  exec { 'create_tmp_dir':
    cwd     => '/',
    path    => ['/usr/bin', '/bin'],
    command => "mkdir -p ${tmp_dir}",
    creates => $tmp_dir;
  }

  file { $tmp_dir:
    ensure  => directory,
    mode    => '0640',
    require => Exec[ 'create_tmp_dir' ]
  }

}
