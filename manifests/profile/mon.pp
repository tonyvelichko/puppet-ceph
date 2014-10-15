class ceph::profile::mon {
  require ceph::profile::base

  Ceph_Config<| |> ->
  ceph::mon { $::hostname:
    authentication_type => $ceph::profile::params::authentication_type,
    key                 => $ceph::profile::params::mon_key,
    keyring             => $ceph::profile::params::mon_keyring
  }

  /*Ceph::Key {
    inject         => true,
    inject_as_id   => 'mon.',
    inject_keyring => "/var/lib/ceph/mon/ceph-${::hostname}/keyring",
  }*/

  if $admin_key {
    ceph::key { 'client.admin':
      secret       => $admin_keyy,
      cap_mon      => 'allow *',
      cap_osd      => 'allow *',
      cap_mds      => 'allow *',
      mode         => '0600',
    }
  }

  if $boostrap_osd_key {
    ceph::key { 'client.bootstrap-osd':
      secret           => $boostrap_osd_key,
      keyring_path     => '/var/lib/ceph/bootstrap-osd/ceph.keyring',
      cap_mon          => 'allow *',
    }
  }

  if $boostrap_mds_key {
    ceph::key { 'client.bootstrap-mds':
      secret           => $boostrap_mds_key,
      keyring_path     => '/var/lib/ceph/bootstrap-mds/ceph.keyring',
      cap_mon          => 'allow *',
    }
  }
}
