# use fqdn when necessary
class eorchestra($port = '5000', $host = $ipaddress, $verificatum_server_ports, $verificatum_hint_server_ports) {
    require user
    require packages
    require verificatum

    file { '/tmp/esetup.sh':
        ensure  => file,
        mode => 'a+x',
        content => template('eorchestra/setup.sh.erb'),
    } ->
    exec { '/tmp/esetup.sh':
        user => 'eorchestra',
        logoutput => true,
        creates => '/home/eorchestra/election-orchestra',
        require => [Package['git'], User['eorchestra'], Python::Virtualenv['/home/eorchestra/venv']],
        timeout => 600,
    } ->
    file { '/tmp/rsetup.sh':
        ensure  => file,
        mode => 'a+x',
        content => template('eorchestra/root_setup.sh.erb'),
    } ->
    exec { '/tmp/rsetup.sh':
        user => 'root',
        logoutput => true,
        timeout => 10,
    } ->
    file {'/home/eorchestra/election-orchestra/auth.ini':
        ensure  => file,
        content => template('eorchestra/auth.ini.erb'),
        owner => 'eorchestra',
    } -> 
    file {'/home/eorchestra/election-orchestra/base_settings.py':
        ensure  => file,
        content => template('eorchestra/base_settings.py.erb'),
        owner => 'eorchestra',
    } ->
    file {'/srv/election-orchestra/':
        ensure  => directory,
        owner => 'eorchestra',
        group => 'users',
    } ->
    file {'/srv/election-orchestra/server1/':
        ensure  => directory,
        owner => 'eorchestra',
        group => 'users',
    } ->
    file {'/srv/election-orchestra/server1/public/':
        ensure  => directory,
        owner => 'eorchestra',
        group => 'users',
    } ->
    file {'/srv/certs/':
        ensure  => directory,
        owner => 'eorchestra',
        group => 'users'
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
    } ->
    file {'/etc/supervisor/conf.d/election-orchestra.conf':
        ensure  => file,
        require => Package['supervisor'],
        content => template('packages/election-orchestra.conf.erb'),
        notify => Service['supervisor'],
    }
}