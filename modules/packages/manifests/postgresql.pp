class packages::postgresql  {
    # postgresql-dev required for Python's psycopg2
    package { [ 'postgresql', 'postgresql-server-dev-all' ]:
        ensure => 'installed',
    } ->
	# workaround for http://projects.puppetlabs.com/issues/4695
    # when PostgreSQL is installed with SQL_ASCII encoding instead of UTF8
    exec { 'utf8 postgres':
        command => 'pg_dropcluster --stop 9.1 main ; pg_createcluster --start --locale C.UTF-8 9.1 main',
        user    => 'postgres',
        unless  => 'psql -t -c "\l" | grep template1 | grep -q UTF',
		provider => shell
    } ->
    service { 'postgresql':
        ensure  => running,
    }
}