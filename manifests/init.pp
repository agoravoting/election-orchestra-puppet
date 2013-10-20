# include eorchestra
class {'eorchestra':
    port => '5000',
    host => 'first-eovm',
    verificatum_server_ports => '[4081, 4083]',
    verificatum_hint_server_ports => '[8081, 8083]'
}