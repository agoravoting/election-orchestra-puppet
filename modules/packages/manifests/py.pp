class packages::py {       
    require user
    
    class { 'python':
        version    => 'system',
        dev        => true,
        virtualenv => true,
        gunicorn   => false,
        pip        => true
    } ->
    file {'/tmp/requirements.txt':
        ensure  => file,
        content => template('packages/requirements.txt.erb'),
        owner => 'eorchestra'
    } ->
    python::virtualenv { '/home/eorchestra/venv':
        ensure       => present,
        version      => 'system',        
        requirements => '/tmp/requirements.txt',                
        systempkgs   => true,
        distribute   => false,
        owner        => 'eorchestra',
        group        => 'eorchestra'
    }
}