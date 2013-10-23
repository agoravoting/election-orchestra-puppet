# include eorchestra
class {'eorchestra':
    port => '5001',
    host => 'second-eovm',
    verificatum_server_ports => '[4082, 4084]',
    verificatum_hint_server_ports => '[8082, 8084]'
}
