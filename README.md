puppet module for logstash
--------------------------

This module will install and manage logstash

###Sample Usage

```
#indexer
class { 'logstash':
  role => 'indexer'
}
#shipper
class { 'logstash':
  role => 'shipper',
  indexer => 'ip_of_indexer'
}
```

Using with puppet apply (given module lives in /root/modules):

```
cd ~ && mkdir modules
cd ~/modules && git clone https://github.com/ashrithr/puppet_logstash.git logstash
#dependecy java module
cd ~/modules && git clone https://github.com/ashrithr/puppet_java.git java
```

Install Logstash Indexer:

```
puppet apply --modulepath=/root/modules/ -e "class {'logstash': role => 'indexer'}"
```

Install Logstash Shipper:

```
puppet apply --modulepath=/root/modules/ -e "class {'logstash': role => 'shipper', indexer => 'localhost'}"
```

Install Lumberjack Agent:

```
puppet apply --modulepath=/root/modules -e "class {'logstash::lumberjack': logstash_host => 'localhost', logfiles => ['/var/log/messages', '/var/log/secure'], field => 'cw_host_1'}"
```

Note: For puppet apply, modules should be located inside modules dir with name as include name:
      Ex: `mkdir -p /root/modules && mv puppet_java /root/modules/java`

To install puppet:

```
wget -qO - https://raw.github.com/ashrithr/scripts/master/install_puppet_standalone.sh | bash
```