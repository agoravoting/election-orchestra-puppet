class packages::java {
    # http://askubuntu.com/questions/190582/installing-java-automatically-with-silent-option
    exec { 'accept-oracle-2':
        command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections',
        logoutput => true,
    } ->
    exec { 'accept-oracle-1':
        command => '/bin/echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections',
        logoutput => true,        
    } ->
    package { 'oracle-java7-installer':
        ensure=> present,
        require => [Exec['accept-oracle-1'], Exec['accept-oracle-2']],
    }
}