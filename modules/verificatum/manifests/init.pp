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
        # FIXME
        # 'puppet:///modules/verificatum/shell/setup.sh':                  
        logoutput => true,
        require => [Package['git'], Package['oracle-java7-installer']],
        creates => '/home/eorchestra/.verificatum_env',
    }
    
}