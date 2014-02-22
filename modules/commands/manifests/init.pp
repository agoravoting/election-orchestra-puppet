class commands() {
    file { '/usr/bin/create_backup.sh':
        ensure  => file,
        mode    => 'a+x',
        content => template('commands/create_backup.sh.erb'),
    } ->

    file { '/root/.backup_password':
        ensure  => file,
        mode    => '0600',
        owner   => 'root',
        content => template('commands/backup_password.erb'),
    } ->

    file { '/usr/bin/restore_backup.sh':
        ensure  => file,
        mode    => 'a+x',
        content => template('commands/restore_backup.sh.erb'),
    } ->

    file { '/usr/bin/eopeers':
        ensure  => file,
        mode    => 'a+x',
        content => template('commands/eopeers.erb'),
    } ->

    file { '/usr/bin/reset-tally':
        ensure  => file,
        mode    => 'a+x',
        content => template('commands/reset-tally.erb'),
    } ->

    file { '/usr/bin/eolog':
        ensure  => file,
        mode    => 'a+x',
        content => template('commands/eolog.erb'),
    } ->

    file { '/usr/bin/eoauto':
        ensure  => file,
        mode    => 'a+x',
        content => template('commands/eoauto.erb'),
    } ->

    file { '/usr/bin/eotest':
        ensure  => file,
        mode    => 'a+x',
        content => template('commands/eotest.erb'),
    } ->

    file { '/usr/bin/eotasks':
        ensure  => file,
        mode    => 'a+x',
        content => template('commands/eotasks.erb'),
    }
}
