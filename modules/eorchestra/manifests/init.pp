class eorchestra {
    require user
    require packages
    require verificatum    
        
    exec { '/vagrant/modules/eorchestra/shell/setup.sh':
        # FIXME
        # 'puppet:///modules/eorchestra/setup.sh':          
        user => 'eorchestra',
        logoutput => true,
        creates => '/home/eorchestra/election-orchestra',
        require => [Package['git'], User['eorchestra'], Python::Virtualenv['/home/eorchestra/venv']],
    } ->
    file {'/home/eorchestra/election-orchestra/auth.ini':
        ensure  => file,        
        content => template('eorchestra/auth.ini.erb'),
    } -> 
    file {'/srv/certs/':
        ensure  => directory,
        owner => 'eorchestra',        
    } ->
    file {'/srv/certs/selfsigned/':
        ensure  => directory,
        owner => 'eorchestra',
        recurse => true,
        source => '/home/eorchestra/election-orchestra/certs/selfsigned'
    } ->
    file {'/etc/nginx/nginx.conf':
        ensure  => file,
        require => Package['nginx'],
        content => template('packages/nginx.conf.erb'),
        notify => Service['nginx'],
    }
}