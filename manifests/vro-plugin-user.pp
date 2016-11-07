class profile::vro-plugin-user (
  String $vro_plugin_user = 'vro-plugin-user',
  String $vro_password = 'puppetlabs',
  String $vro_password_hash = '$1$Fq9vkV1h$4oMRtIjjjAhi6XQVSH6.Y.', #puppetlabs
  #String $vro_home_dir = "/home/${vro-plugin-user}",
  #String $vro_key_dir = "${vro_home_dir}/.ssh",
  #String $vro_key_file = "${vro_key_dir}/id.rsa",
  #String $vro_token_dir = "${vro_home_dir}/.puppetlabs",
  #String $vro_token_file = "${vro_token_dir}/token",
  #String $root_token_dir = '/root/.puppetlabs',
  #String $root_token_file = "${root_token_dir}/token",
) {
  # vro user's ssh keys
  #file { $vro_key_dir:
  #  ensure => directory,
  #  owner  => $vro-plugin-user,
  #  group  => $vro-plugin-user,
  #  mode   => '0700',
  #  require => File[$vro_home_dir],
  #}

  #exec { "create ${vro-plugin-user} ssh key":
  #  command => "/usr/bin/ssh-keygen -t rsa -b 2048 -C '${vro-plugin-user}' -f ${vro_key_file} -q -N ''",
  #  creates => $vro_key_file,
  #  require => File[$vro_key_dir],
  #}

  # private key
  #file { $vro_key_file:
  #  ensure  => file,
  #  owner   => $vro-plugin-user,
  #  group   => $vro-plugin-user,
  #  mode    => '0600',
  #  require => Exec["create ${vro-plugin-user} ssh key"],
  #}

  # public key
  #file { "${vro_key_file}.pub":
  #  ensure  => file,
  #  owner   => $vro-plugin-user,
  #  group   => $vro-plugin-user,
  #  mode    => '0644',
  #  require => Exec["create ${vro-plugin-user} ssh key"],
  #}

  $ruby_mk_vro-plugin-user = epp('profile/create_user_role.rb.epp', {
    'username'    => $vro-plugin-user,
    'password'    => $vro_password,
    'rolename'    => 'VRO User to clean removed nodes,
    'touchfile'   => '/opt/puppetlabs/puppet/cache/vro-plugin-user_created',
    'permissions' => [
      { 'action'      => 'view_data',
        'instance'    => '*',
        'object_type' => 'nodes',
      },
    ],
  })

  exec { 'create vro user and role':
    command => "/opt/puppetlabs/puppet/bin/ruby -e ${shellquote($ruby_mk_vro-plugin-user)}",
    creates => '/opt/puppetlabs/puppet/cache/vro-plugin-user_created',
  }

  # The puppet-access command will create any needed directories and make root their owner. So for the vro and deploy users we have to run the command
  # first and then manage the ownership later so pe-puppet can read during template file() function evaluation.
  exec { "create ${vro-plugin-user} rbac token":
    command => "/bin/echo ${shellquote($vro_password)} | \
                  /opt/puppetlabs/bin/puppet-access login \
                  --username ${vro-plugin-user} \
                  --service-url https://${clientcert}:4433/rbac-api \
                  --lifetime 1y \
                  --token-file ${vro_token_file}",
    creates => $vro_token_file,
    require => Exec['create vro user and role'],
  }

  user { $vro-plugin-user:
    ensure   => present,
    #home     => $vro_home_dir,
    shell    => '/bin/bash',
    password => $vro_password_hash,
    require  => Exec["create ${vro-plugin-user} rbac token"],
  }

  #file { $vro_home_dir:
  #  ensure  => directory,
  #  owner   => $vro-plugin-user,
  #  group   => $vro-plugin-user,
  #  require => User[$vro-plugin-user],
  #}

  #file { "${vro_home_dir}/.profile":
  #  ensure  => file,
  #  require => File[$vro_home_dir],
  #  owner   => $vro-plugin-user,
  #  group   => $vro-plugin-user,
  #  content => epp('profile/vro-plugin-user_dotprofile.epp', {
  #    'vro_key_file' => $vro_key_file
  #  }),
  #}

  #file { $vro_token_dir:
  #  ensure  => directory,
  #  owner   => $vro-plugin-user,
  #  group   => $vro-plugin-user,
  #  require => File[$vro_home_dir],
  #}

  #file { $vro_token_file:
  #  ensure  => file,
  #  owner   => $vro-plugin-user,
  #  group   => $vro-plugin-user,
  #  mode    => '0600',
  #  require => Exec["create ${vro-plugin-user} rbac token"],
  }

  file { $root_token_dir:
    ensure  => directory,
    owner   => root,
    group   => root,
    require => Exec["create ${vro-plugin-user} rbac token"],
  }

  file { $root_token_file:
    ensure => link,
    target => $vro_token_file,
  }
}
