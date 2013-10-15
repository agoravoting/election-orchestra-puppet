class packages::py {       
    require user
    
    class { 'python':
        version    => 'system',
        dev        => true,
        virtualenv => true,
        gunicorn   => false,
        pip        => true
    } ->
    python::virtualenv { '/home/eorchestra/venv':
        ensure       => present,
        version      => 'system',
        # FIXME
        requirements => '/vagrant/modules/packages/requirements.txt',        
        #requirements => 'puppet:///modules/packages/requirements.txt',
        systempkgs   => true,
        distribute   => false,
        owner        => 'eorchestra',
        group        => 'eorchestra'
    }
}