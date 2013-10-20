class packages::supervisor {
    package { "supervisor":
        ensure=>present,
    } ->
    service { 'supervisor':
        ensure     => running,
        enable     => true,
        restart => 'supervisorctl reload',
    }
}