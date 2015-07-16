  file { 'test_param_file_path':
    path => "/home/$user/foo.txt",
    ensure => file,
    content => 'Here is some stuff in my file',
  }
