class ceph::profile::base (
  $fsid = '4b5c8c0a-ff60-454b-a1b4-9747aa737d19',
  $release = undef,
  $authentication_type = undef,
  $mon_initial_members = undef,
  $mon_host = undef,
  $osd_pool_default_pg_num = undef,
  $osd_pool_default_pgp_num = undef,
  $osd_pool_default_size = undef,
  $osd_pool_default_min_size = undef,
  $cluster_network = undef,
  $public_network = undef,
  $admin_key = undef,
  $admin_key_mode = undef,
  $mon_key = undef,
  $mon_keyring = undef,
  $bootstrap_osd_key = undef,
  $bootstrap_mds_key = undef,
  $osds = undef,
  $extra = false,
  $fast_cgi = false,
){
  class { 'ceph::profile::params':
    fsid                      => $fsid,
    release                   => $release,
    authentication_type       => $authentication_type,
    mon_initial_members       => $mon_initial_members,
    mon_host                  => $mon_host,
    osd_pool_default_pg_num   => $osd_pool_default_pg_num,
    osd_pool_default_pgp_num  => $osd_pool_default_pgp_num,
    osd_pool_default_size     => $osd_pool_default_size,
    osd_pool_default_min_size => $osd_pool_default_min_size,
    cluster_network           => $cluster_network,
    public_network            => $public_network,
    admin_key                 => $admin_key,
    admin_key_mode            => $admin_key_mode,
    mon_key                   => $mon_key,
    mon_keyring               => $mon_keyring,
    bootstrap_osd_key         => $bootstrap_osd_key,
    bootstrap_mds_key         => $bootstrap_mds_key,
    osds                      => $osds,
  } ->

  class { 'ceph::repo':
    release => $ceph::profile::params::release,
    extras  => $extra,
    fastcgi => $fast_cgi,
  } ->

  class { 'ceph':
    fsid                      => $ceph::profile::params::fsid,
    authentication_type       => $ceph::profile::params::authentication_type,
    osd_pool_default_pg_num   => $ceph::profile::params::osd_pool_default_pg_num,
    osd_pool_default_pgp_num  => $ceph::profile::params::osd_pool_default_pgp_num,
    osd_pool_default_size     => $ceph::profile::params::osd_pool_default_size,
    osd_pool_default_min_size => $ceph::profile::params::osd_pool_default_min_size,
    mon_initial_members       => $ceph::profile::params::mon_initial_members,
    mon_host                  => $ceph::profile::params::mon_host,
    cluster_network           => $ceph::profile::params::cluster_network,
    public_network            => $ceph::profile::params::public_network,
  }
}
