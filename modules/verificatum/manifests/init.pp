class verificatum {
    require packages

    package { 'make':
        ensure=> present,
    } ->
    package { 'm4':
        ensure=> present,
    } ->
    package { 'libgmp-dev':
        ensure=> present,
    } ->
    file { '/tmp/vsetup.sh':
        ensure => file,
        mode => 'a+x',
        content => template('verificatum/setup.sh.erb'),
    }
    exec { '/tmp/vsetup.sh':
        logoutput => true,
        require => [Package['git']],
        creates => '/home/eorchestra/.verificatum_env',
        timeout => 600,
    }
}