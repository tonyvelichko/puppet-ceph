define ceph::mon (
  $ensure = present,
  $public_addr = undef,
  $cluster = undef,
  $authentication_type = 'cephx',
  $key = undef,
  $keyring  = undef,
) {

# a puppet name translates into a ceph id, the meaning is different
  $id = $name

  if $cluster {
    $cluster_name = $cluster
    $cluster_option = "--cluster ${cluster_name}"
  } else {
    $cluster_name = 'ceph'
  }

  if $::operatingsystem == 'Ubuntu' {
    $init = 'upstart'
    Service {
      name     => "ceph-mon-${id}",
    # workaround for bug https://projects.puppetlabs.com/issues/23187
      provider => 'init',
      start    => "start ceph-mon id=${id} $cluster_option",
      stop     => "stop ceph-mon id=${id} $cluster_option",
      status   => "status ceph-mon id=${id} $cluster_option",
    }
  } elsif ($::operatingsystem == 'Debian') or ($::osfamily == 'RedHat') {
    $init = 'sysvinit'
    Service {
      name     => "ceph-mon-${id}",
      start    => "service ceph start mon.${id} $cluster_option",
      stop     => "service ceph stop mon.${id} $cluster_option",
      status   => "service ceph status mon.${id} $cluster_option",
    }
  } else {
    fail("operatingsystem = ${::operatingsystem} is not supported")
  }

  $mon_service = "ceph-mon-${id}"

  if $ensure == present {

    $ceph_mkfs = "ceph-mon-mkfs-${id}"

    if ! $key and ! $keyring {
      fail("authentication_type ${authentication_type} requires either key or keyring to be set but both are undef")
    }
    if $key and $keyring {
      fail("key (set to ${key}) and keyring (set to ${keyring}) are mutually exclusive")
    }
    if $key {
      $keyring_path = "/tmp/ceph-mon-keyring-${id}"

      file { $keyring_path:
        mode        => '0444',
        content     => "[mon.]\n\tkey = ${key}\n\tcaps mon = \"allow *\"\n",
      }

      File[$keyring_path] -> Exec[$ceph_mkfs]

    } else {
      $keyring_path = $keyring
    }

    if $public_addr {
      $public_addr_option = "--public_addr ${public_addr}"
    }

    Ceph_Config<||> ->
    exec { $ceph_mkfs:
      command   => "/bin/true # comment to satisfy puppet syntax requirements
set -ex
mon_data=\$(ceph-mon ${cluster_option} --id ${id} --show-config-value mon_data)
if [ ! -d \$mon_data ] ; then
  mkdir -p \$mon_data
  if ceph-mon ${cluster_option} \
        ${public_addr_option} \
        --mkfs \
        --id ${id} \
        --keyring ${keyring_path} ; then
    touch \$mon_data/done \$mon_data/${init} \$mon_data/keyring
  else
    rm -fr \$mon_data
  fi
fi
        ",
      logoutput => true,
    }
    ->
    # prevent automatic creation of the client.admin key by ceph-create-keys
    exec { "ceph-mon-${cluster_name}.client.admin.keyring-${id}":
      command => "/bin/true # comment to satisfy puppet syntax requirements
set -ex
touch /etc/ceph/${cluster_name}.client.admin.keyring",
    }
    ->
    service { $mon_service:
      ensure => running,
    }


    if $authentication_type == 'cephx' {
      if $key {
        Exec[$ceph_mkfs] -> Exec["rm-keyring-${id}"]

        exec { "rm-keyring-${id}":
          command => "/bin/rm ${keyring_path}",
        }
      }
    }

  } else {
    service { $mon_service:
      ensure => stopped
    }
    ->
    exec { "remove-mon-${id}":
      command   => "/bin/true  # comment to satisfy puppet syntax requirements
set -ex
mon_data=\$(ceph-mon ${cluster_option} --id ${id} --show-config | sed -n -e 's/mon_data = //p')
rm -fr \$mon_data
",
      logoutput => true,
    } -> Package<| tag == 'ceph' |>
  }
}
