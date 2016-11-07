## VRO-Plugin-User account.  This user will be used for querying PuppetDB for the node that was deployeed, through VRO/VRA Plugin.
## The user will then be able to purge certificate for the node, thus disalowing communication between node and master.

class vro_plugin_user {

  user { 'vro-plugin-user':
    ensure   => present,
    comment  => 'VRO Plugin User',
    shell    => '/bin/bash',
    password => pw_hash('puppetlabs', 'SHA-512', 'mysalt'),
  }

  file { '/etc/sudoers.d/vro-plugin-user':
    ensure  => file,
    mode    => '0440',
    owner   => 'root',
    group   => 'root',
    content => epp('profile/vro-plugin-user.epp'),
  }

}
