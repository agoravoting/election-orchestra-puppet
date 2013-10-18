class user {
    user { 'eorchestra':
      ensure     => present,      
      home       => '/home/eorchestra',
      managehome => true,
      shell => '/bin/sh'
    }
}