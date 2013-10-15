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
    exec { '/vagrant/modules/verificatum/shell/setup.sh':
        # FIXME
        # 'puppet:///modules/verificatum/shell/setup.sh':                  
        logoutput => true,
        require => [Package['git'], Package['oracle-java7-installer']],
    }
    
}