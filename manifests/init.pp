# == Class: cassandra
#
# Installs and configures a Cassandra server
#
# (Much of this module was adapted from:
# https://github.com/msimonin/puppet-cassandra)
#
# Note:  This class requires the Puppet stdlib module, particularly the pick() function.
#
# === Usage
# class { '::cassandra':
#     cluster_name => 'my_cluster',
#     seeds        => ['10.11.12.13', '10.11.13.14'],
#     dc           => 'my_datacenter1',
#     rack         => 'my_rack1',
# #   ...
# }
#
# === Parameters
# [*cluster_name*]
#   The logical name of this Cassandra cluster.
#   Default: Test Cluster
#
# [*seeds*]
#   Array of seed IPs for this Cassandra cluster.
#   Default: [$::ipaddress]
#
# [*num_tokens*]
#   Number of tokens randomly assigned to this node on the ring.
#   Default: 256
#
# [*authenticator*]
#   Authentication backend, implementing IAuthenticator; used to identify users.
#   If false, AllowAllAuthenticator will be used.
#   If true, PasswordAuthenticator will be used.
#   Else, the value provided will be used.
#   Default: true
#
# [*authorizor*]
#   Authorization backend, implementing IAuthorizer; used to limit access/provide permissions.
#   If false, AllowAllAuthorizer will be used.
#   If true, CassandraAuthorizer will be used.
#   Else, the value provided will be used.
#   Default: true
#
# [*data_file_directories*]
#   Array of directories where Cassandra should store data on disk.
#   This module will not set up partitions or RAID, so make sure
#   You have these directories configured as you like and mounted
#   before you apply this module.
#   Default: [/var/lib/cassandra/data]
#
# [*commitlog_directory*]
#   Directory where Cassandra should store its commit log.
#   Default: /var/lib/cassandra/commitlog
#
# [*disk_failure_policy*]
#   Policy for data disk failure.  Should be one of:
#   stop_paranoid, stop, best_effort, or ignore.
#   Default: stop
#
# [*memory_allocator*]
#   The off-heap memory allocator.
#   Default: JEMallocAllocator
#
# [*saved_caches_directory*]
#   Directory where Cassandra should store saved caches.
#   Default: /var/lib/cassandra/saved_caches
#
# [*concurrent_reads*]
#   Number of allowed concurrent reads.  Should be set to
#   (16 * number_of_drives) in your data_file_directories.
#   Default: 32
#
# [*concurrent_writes*]
#   Number of allowed concurrent writes.  Should be set to
#   about (8 * number_of_cores).  This is also the default.
#   Default: $::processorcount * 8
#
# [*storage_port*]
#   TCP port, for commands and data.
#   Default: 7000
#
# [*listen_address*]
#   Cassandra listen IP address.  Default $::ipaddress
#
# [*broadcast_address*]
#   IP address to broadcast to other Cassandra nodes.  Default: undef (uses $listen _address)
#
# [*start_native_transport*]
#   Whether to start the native transport server.  Default: true
#
# [*native_transport_port*]
#   Native transport listen port.  Default: 9042
#
# [*start_rpc*]
#   Whether to start the thrift rpc server.  Default: true
#
# [*rpc_address*]
#   IP address to bind the Thrift RPC service and native transport server.  Default: $::ipaddress
#
# [*rpc_port*]
#   Port for Thrift to listen for clients on.  Default: 9160
#
# [*rpc_server_type*]
#   RPC server type, either 'sync' or 'hsha' (half sync, half async).  Default: sync
#
# [*incremental_backups*]
#   If true, Cassandra will create incremental hardlink backups.
#   Default: false
#
# [*snapshot_before_compaction*]
#   Whether or not to take a snapshot before each compaction.
#   Default: false
#
# [*auto_snapshot*]
#   Whether or not a snapshot is taken of the data before keyspace
#   truncation or dropping of column families.
#   Default: true
#
# [*compaction_throughput_mb_per_sec*]
#    Throttles compaction to the given total throughput across
#    the entire system.
#    Default: 16
#
# [*endpoint_snitch*]
#   Set this to a class that implements IEndpointSnitch.
#   Default: GossipingPropertyFileSnitch
#
# [*internode_compression*]
#   Controls whether traffic between nodes is compressed.
#   Should be one of: all, dc, or none
#   Default: all
#
# [*max_heap_size*]
#   Value for -Xms and -Xmx to pass to the JVM.
#   Default: undef
#
# [*heap_newsize*]
#   Value for -Xmn to pass to the JVM.
#   Default: undef
#
# [*additional_jvm_opts*]
#   Additional options to pass to the JVM.
#   Default: undef
#
# [*jmx_port*]
#   Port to listen for JMX queries.
#   Default: 7199
#
# [*dc*]
#   Logical name datacenter name.  This will only be used
#   if $endpoint_snitch is GossipingPropertyFileSnitch.
#   Default:  dc1
#
# [*rack*]
#   Logical rack name.  This will only be used
#   if $endpoint_snitch is GossipingPropertyFileSnitch.
#   Default rack1
#
class cassandra(
    $cluster_name                     = $cassandra::defaults::cluster_name,
    $seeds                            = $cassandra::defaults::seeds,
    $num_tokens                       = $cassandra::defaults::num_tokens,
    $authenticator                    = $cassandra::defaults::authenticator,
    $authorizor                       = $cassandra::defaults::authorizor,
    $data_file_directories            = $cassandra::defaults::data_file_directories,
    $commitlog_directory              = $cassandra::defaults::commitlog_directory,
    $disk_failure_policy              = $cassandra::defaults::disk_failure_policy,
    $memory_allocator                 = $cassandra::defaults::memory_allocator,
    $saved_caches_directory           = $cassandra::defaults::saved_caches_directory,
    $concurrent_reads                 = $cassandra::defaults::concurrent_reads,
    $concurrent_writes                = $cassandra::defaults::concurrent_writes,
    $storage_port                     = $cassandra::defaults::storage_port,
    $listen_address                   = $cassandra::defaults::listen_address,
    $broadcast_address                = $cassandra::defaults::broadcast_address,
    $start_native_transport           = $cassandra::defaults::start_native_transport,
    $native_transport_port            = $cassandra::defaults::native_transport_port,
    $start_rpc                        = $cassandra::defaults::start_rpc,
    $rpc_address                      = $cassandra::defaults::rpc_address,
    $rpc_port                         = $cassandra::defaults::rpc_port,
    $rpc_server_type                  = $cassandra::defaults::rpc_server_type,
    $incremental_backups              = $cassandra::defaults::incremental_backups,
    $snapshot_before_compaction       = $cassandra::defaults::snapshot_before_compaction,
    $auto_snapshot                    = $cassandra::defaults::auto_snapshot,
    $compaction_throughput_mb_per_sec = $cassandra::defaults::compaction_throughput_mb_per_sec,
    $endpoint_snitch                  = $cassandra::defaults::endpoint_snitch,
    $internode_compression            = $cassandra::defaults::internode_compression,
    $max_heap_size                    = $cassandra::defaults::max_heap_size,
    $heap_newsize                     = $cassandra::defaults::heap_newsize,
    $jmx_port                         = $cassandra::defaults::jmx_port,
    $additional_jvm_opts              = $cassandra::defaults::additional_jvm_opts,
    $dc                               = $cassandra::defaults::dc,
    $rack                             = $cassandra::defaults::rack,

    $yaml_template                    = $cassandra::defaults::cassandra_yaml_template,
    $env_template                     = $cassandra::defaults::cassandra_env_template,
    $rackdc_template                  = $cassandra::defaults::cassandra_rackdc_template
) inherits cassandra::defaults
{
    validate_string($cluster_name)

    validate_absolute_path($commitlog_directory)
    validate_absolute_path($saved_caches_directory)

    validate_string($initial_token)
    validate_string($endpoint_snitch)

    validate_re($start_rpc, '^(true|false)$')
    validate_re($start_native_transport, '^(true|false)$')
    validate_re($rpc_server_type, '^(hsha|sync|async)$')
    validate_re($incremental_backups, '^(true|false)$')
    validate_re($snapshot_before_compaction, '^(true|false)$')
    validate_re($auto_snapshot, '^(true|false)$')
    validate_re("${concurrent_reads}", '^[0-9]+$')
    validate_re("${concurrent_writes}", '^[0-9]+$')
    validate_re("${num_tokens}", '^[0-9]+$')
    validate_re($internode_compression, '^(all|dc|none)$')
    validate_re($disk_failure_policy, '^(stop|best_effort|ignore)$')

    validate_array($additional_jvm_opts)

    if (!is_integer($jmx_port)) {
        fail('jmx_port must be a port number between 1 and 65535')
    }

    if (!is_ip_address($listen_address)) {
        fail('listen_address must be an IP address')
    }

    if (!empty($broadcast_address) and !is_ip_address($broadcast_address)) {
        fail('broadcast_address must be an IP address')
    }

    if (!is_ip_address($rpc_address)) {
        fail('rpc_address must be an IP address')
    }

    if (!is_integer($rpc_port)) {
        fail('rpc_port must be a port number between 1 and 65535')
    }

    if (!is_integer($native_transport_port)) {
        fail('native_transport_port must be a port number between 1 and 65535')
    }

    if (!is_integer($storage_port)) {
        fail('storage_port must be a port number between 1 and 65535')
    }

    if (empty($seeds)) {
        fail('seeds must not be empty')
    }

    if (empty($data_file_directories)) {
        fail('data_file_directories must not be empty')
    }


    # Choose real authenticator and authorizor values
    $authenticator_value = $authenticator ? {
        true    => 'PasswordAuthenticator',
        false   => 'AllowAllAuthenticator',
        default => $authenticator,
    }
    $authorizor_value = $authorizor ? {
        true    => 'CassandraAuthorizer',
        false   => 'AllowAllAuthorizer',
        default => $authorizor,
    }

    package { 'cassandra':
        ensure  => 'installed',
    }

    # Make sure libjemalloc is installed if
    # we are going to use the JEMallocAllocator.
    if $memory_allocator == 'JEMallocAllocator' {
        package { 'libjemalloc1':
            ensure => 'installed',
        }
    }

    file { $data_file_directories:
        ensure  => directory,
        owner   => 'cassandra',
        group   => 'cassandra',
        require => Package['cassandra'],
    }

    file { '/etc/cassandra/cassandra-env.sh':
        content => template("${module_name}/cassandra-env.sh.erb"),
        owner   => 'cassandra',
        group   => 'cassandra',
    }

    file { '/etc/cassandra/cassandra.yaml':
        content => template("${module_name}/cassandra.yaml.erb"),
        owner   => 'cassandra',
        group   => 'cassandra',
        require => Package['cassandra'],
    }

    # cassandra-rackdc.properties is used by the
    # GossipingPropertyFileSnitch.  Only render
    # it if we are using that endpoint_snitch.
    $rackdc_properties_ensure = $endpoint_snitch ? {
        'GossipingPropertyFileSnitch' => file,
        default                       => 'absent',
    }
    file { '/etc/cassandra/cassandra-rackdc.properties':
        ensure  => $rackdc_properties_ensure,
        content => template("${module_name}/cassandra-rackdc.properties.erb"),
        owner   => 'cassandra',
        group   => 'cassandra',
        require => Package['cassandra'],
    }

    # This Puppet module does not support
    # PropertyFileSnitch, which uses these files.
    file { ['/etc/cassandra/cassandra-topology.properties', '/etc/cassandra/cassandra-topology.yaml']:
        ensure => 'absent',
    }

    service { 'cassandra':
        ensure     => 'running',
        enable     => true,
        hasstatus  => true,
        hasrestart => true,
        # This module does not subscribe to its config files,
        # as we would like to manage service restarts manually.
        require    => [
            File[$data_file_directories],
            File['/etc/cassandra/cassandra-env.sh'],
            File['/etc/cassandra/cassandra.yaml'],
            File['/etc/cassandra/cassandra-rackdc.properties'],
            File['/etc/cassandra/cassandra-topology.properties'],
            File['/etc/cassandra/cassandra-topology.yaml'],
        ],
    }
}