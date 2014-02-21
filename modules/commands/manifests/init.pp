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
    }
}