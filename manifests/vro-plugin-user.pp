class plugin_user (
  String $vro_plugin_user = 'vro-plugin-user',
  String $vro_password = 'puppetlabs',
  String $vro_password_hash = '$1$Fq9vkV1h$4oMRtIjjjAhi6XQVSH6.Y.', #puppetlabs
 ){

  $ruby_mk_vro_plugin_user = epp('profile/create_user_role.rb.epp', {
    'username'    => $vro_plugin_user,
    'password'    => $vro_password,
    'rolename'    => 'VRO User to clean removed nodes,
    'touchfile'   => '/opt/puppetlabs/puppet/cache/vro_plugin_user_created',
    'permissions' => [
      { 'action'      => 'view_data',
        'instance'    => '*',
        'object_type' => 'nodes',
      },
    ],
  })

  exec { 'create vro user and role':
    command => "/opt/puppetlabs/puppet/bin/ruby -e ${shellquote($ruby_mk_vro_plugin_user)}",
    creates => '/opt/puppetlabs/puppet/cache/vro_plugin_user_created',
  }

##Creates system user.

  user { $vro_plugin_user:
    ensure   => present,
    shell    => '/bin/bash',
    password => $vro_password_hash,
    require  => Exec["create ${vro_plugin_user} rbac token"],
  }

## Manage /etc/sudoers.d/vro-plugin-user file.  This allows and disallows sudo commands.

  file { '/etc/sudoers.d/vro-plugin-user':
    ensure  => file,
    mode    => '0440',
    owner   => 'root',
    group   => 'root',
    content => epp('profile/vro-sudoer-file.epp'),
  }
}
