# == Class: logstash
#             logstash::config
#             logstash::elasticsearch
#             logstash::kibana
#             logstash::lumberjack
#             logstash::package
#             logstash::params
#             logstash::redis
#             logstash::service
#
# This module will install and manage logstash with lumberjack, redis, elasticsearch
#
# === Parameters
#
# [*role*]
#   role of the logstash daemon
#     indexer: will install logstash server, redis server, elasticsearch server
#     shipper: will install logstash agent
#     lumberjack: will install lumberjack which will serve as logstash agent
#
# [*indexer*]
#   fqdn or ip of the logstash indexer, required for agnets to report to
#
# [*lj_logs*]
#   a list of log files path for the lumberjack to monitor
#   ex: ['/var/log/syslog', '/var/log/hadoop-hdfs/hadoop-namenode*'] (or) [ '/var/log/*.log' ]
#
# [*lj_fields*]
#   a custom field name, if provided will be used as a tag from that host
#
# === Variables
#
# Nothing.
#
# === Requires
#
# Java
#
# === Sample Usage
#
# See README.md

class logstash(
  $role,
  $indexer = undef,
  $lj_logs = undef,
  $lj_fields = undef
  ) inherits logstash::params {

  if ! ($role in [ 'indexer', 'shipper', 'lumberjack' ]) {
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
  }
  elsif $role == 'shipper' {
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
  else {
    notice('installing role lumberjack (agent)')
    #lumberjack agent requires
    # - a indexer(hostname|ip) to send events to
    # - a list of log files to monitor
    # - field_name used for tag
    # - port on which logstash is listening for lumberjack input
    if $indexer == undef {
      fail("\"${role}\" requires hostname|ip of indexer")
    }
    if $lj_logs == undef {
      fail("\"${role}\" requires array of log files to send to logstash indexer")
    }
    if $lj_fields == undef {
      $lumberjack_tag_fields = 'lumberjack_host'
    } else {
      $lumberjack_tag_fields = $lj_fields
    }
    class { 'logstash::lumberjack':
      $logstash_host => $indexer,
      $logstash_port => $logstash::params::logstash_lumberjack_port,
      $logfiles => $lj_logs,
      $field => $lumberjack_tag_fields
    }
  }

}