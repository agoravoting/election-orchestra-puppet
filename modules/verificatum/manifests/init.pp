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
    file { '/vagrant/modules/verificatum/shell/setup.sh':
        mode => 'a+x'
    }
    exec { '/vagrant/modules/verificatum/shell/setup.sh':
        # FIXME
        # 'puppet:///modules/verificatum/shell/setup.sh':                  
        logoutput => true,
        require => [Package['git'], Package['oracle-java7-installer']],
        creates => '/home/eorchestra/.verificatum_env',
    }
    
}