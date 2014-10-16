class ceph::profile::mon {
  require ceph::profile::base

  Ceph_Config<| |> ->
  ceph::mon { $::hostname:
    authentication_type => $ceph::profile::params::authentication_type,
    key                 => $ceph::profile::params::mon_key,
    keyring             => $ceph::profile::params::mon_keyring
  }

  if $ceph::profile::params::admin_key {
    ceph::key { 'client.admin':
      secret       => $ceph::profile::params::admin_key,
      cap_mon      => 'allow *',
      cap_osd      => 'allow *',
      cap_mds      => 'allow *',
      mode         => '0600',
    }
    
    ceph::key { 'client.radosgw.gateway':
      secret       => $ceph::profile::params::admin_key,
      cap_mon      => 'allow *',
      cap_osd      => 'allow *',
      cap_mds      => 'allow *',
      mode         => '0600',
    }
  }

  if $ceph::profile::params::bootstrap_osd_key {
    ceph::key { 'client.bootstrap-osd':
      secret           => $ceph::profile::params::bootstrap_osd_key,
      keyring_path     => '/var/lib/ceph/bootstrap-osd/ceph.keyring',
      cap_mon          => 'allow *',
    }
  }

  if $ceph::profile::params::boostrap_mds_key {
    ceph::key { 'client.bootstrap-mds':
      secret           => $ceph::profile::params::boostrap_mds_key,
      keyring_path     => '/var/lib/ceph/bootstrap-mds/ceph.keyring',
      cap_mon          => 'allow *',
    }
  }
}
