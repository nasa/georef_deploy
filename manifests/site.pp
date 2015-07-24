
include apt
include stdlib

# $user, $site, $dev_instance set in /etc/facter/facts.d/xgds.json -- see setup_site.py

$deploy = "/home/$user/puppet/xgds_${site}_deploy"
$sitedir = "/home/$user/gds/xgds_${site}"

#################################################################
# MARIA DB PACKAGE Source

class mariadb_repo {
  apt::source { "mariadb":
    location => "http://ftp.utexas.edu/mariadb/repo/10.0/ubuntu",
    release => "trusty",
    repos => "main",
    include => {
      'src' => false,
      'deb' => true,
    },
    key => {
      id => '199369E5404BD5FC7D2FE43BCBCB082A1BB943DB',
      server => 'hkp://keyserver.ubuntu.com:80',
    },
    before => Exec['apt-update']
  }
  exec { 'apt-update':
    command => "/usr/bin/apt-get -y update && /usr/bin/touch /home/$user/.apt_updated",
    creates => "/home/$user/.apt_updated",
  }
}

class { 'mariadb_repo': }
Class['mariadb_repo'] -> Class['ubuntu_packages']

#################################################################
# UBUNTU PACKAGES

class ubuntu_packages {
  package { 'ntp': }
  package { 'build-essential': }
  package { 'nfs-common': }
  package { 'python2.7': }
  package { 'python-dev': }
  package { 'python-imaging': }
  package { 'python-scipy': }
  package { 'git': }
  package { 'libevent-dev': }
  package { 'ruby-full':}
  package { 'python-setuptools': }
  package { 'python-pip': }
  package { 'npm':}
  package { 'nodejs-legacy':}
  package { 'subversion':}
  package { 'gkermit':}
  package { 'couchdb':}
  package { 'libproj-dev': }
  package { 'gdal-bin': }

  # optional - for dev
  package { 'emacs': }

  # optional - includes useful 'reindent.py' script for dev
  package { 'python-examples': }

  # optional - provides useful 'ack' command for dev
  package { 'ack-grep': }
  file { '/usr/bin/ack':
    ensure => link,
    target => '/usr/bin/ack-grep',
    require => Package['ack-grep'],
  }

  # optional - needed for pykml
  package { 'python-lxml': }

  # MariaDB uses an engine called TokuDB that requires the GRUB
  # setting transparent_hugepage=never. We need to put our grub config
  # file in one of two places, depending on the flavor of Ubuntu we
  # are using (server ISO vs "cloud image" used by Vagrant). We'll
  # just write to both locations (sigh).
  file { '/etc/default/grub':
    ensure => file,
    source => "${deploy}/etc/grub-defaults",
  }
  #file { '/etc/default/grub.d/50-cloudimg-settings.cfg':
  #  ensure => file,
  #  source => "${deploy}/etc/grub-defaults",
  #}

  exec { 'grub-setup':
    command => '/usr/sbin/grub-mkconfig -o /boot/grub/grub.cfg',
    require => [
      File['/etc/default/grub'],
      # File['/etc/default/grub.d/50-cloudimg-settings.cfg'],
    ],
  }

  # The config file stuff above makes a persistent change to the
  # transparent_hugepages setting. This command redundantly does a
  # one-time fix so we don't have to reboot partway through
  # provisioning to pick up the config file change.
  exec { 'immediate_transparent_hugepages':
    command => "/bin/echo never > /sys/kernel/mm/transparent_hugepage/enabled && /usr/bin/touch /home/$user/.hugepage_fixed && sudo /usr/sbin/service mysql restart",
    creates => "/home/$user/.hugepage_fixed"
  }
}

class { 'ubuntu_packages': }

#################################################################
# PIP PACKAGES

class pip_packages {
  package { 'django':
    ensure => '1.7.3',
    provider => 'pip',
  }
  package { 'django-pipeline':
    provider => 'pip',
  }
  package { 'django-compressor':
    provider => 'pip',
  }
  package { 'pyScss':
    provider => 'pip',
  }
  package { 'django-reversion':
    provider => 'pip',
  }
  package { 'django-sphinx':
    provider => 'pip',
  }
  package { 'pyproj':
    provider => 'pip',
  }
  package { 'iso8601':
    provider => 'pip',
  }
  package { 'pytz':
    provider => 'pip',
  }
  package { 'django-taggit':
    provider => 'pip',
    source => 'git+git://github.com/tamarmot/django-taggit.git#egg=django-taggit',
  }
  package { 'django-filter':
    provider => 'pip',
    source => 'git+https://github.com/alex/django-filter.git@d9f3b20973c35da3f2746b1e445249ac51b36bae#egg=django_filter-0.5.5a1-py2.6-dev',
  }
  package { 'gdata':
    provider => 'pip',
  }
  package { 'pyzmq':
    provider => 'pip',
  }
  # this rule fixes a problem in the pyzmq permissions after install
  exec { 'pyzmq-readable':
    command => "/usr/bin/sudo /bin/chmod -R a+rX /usr/local/lib/python2.7/dist-packages/zmq && /usr/bin/touch /home/$user/.pyzmq-readable",
    creates => "/home/$user/.pyzmq-readable",
    require => Package['pyzmq'],
  }
  package { 'gevent':
    provider => 'pip',
  }
  package { 'msgpack-python':
    provider => 'pip',
  }
  package { 'zerorpc':
    provider => 'pip',
    require => [Exec['pyzmq-readable'], Package['gevent']],
  }
  package { 'ipython':
    provider => 'pip',
  }
  package { 'tornado':
    provider => 'pip',
  }

  package { 'django-tagging':
    provider => 'pip',
  }

  # Lets us run git from python to check out code
  package { 'GitPython':
    provider => 'pip',
  }

  package { 'rdflib':
    provider => 'pip',
    ensure => '2.4.2',
  }

  # optional - handy for debugging
  package { 'django-debug-toolbar':
    provider => 'pip',
  }

  # optional - needed for manage.py lint
  package { 'pylint':
    provider => 'pip',
  }
  package { 'pep8':
    provider => 'pip',
  }
  package { 'django-bower':
    provider => 'pip',
  }
  # m3u8 playlist parser for xgds_video
  package { 'm3u8':
    provider => 'pip',
  }
  # this doesn't work as expected; replaced with exec resource below
  #package { 'closure-linter':
  #  source => 'http://closure-linter.googlecode.com/files/closure_linter-latest.tar.gz',
  #  provider => 'pip',
  #}
  exec { 'closure-linter':
     command => "/usr/bin/pip install http://closure-linter.googlecode.com/files/closure_linter-latest.tar.gz && touch /home/$user/.installed-closure-linter",
     creates => "/home/$user/.installed-closure-linter",
     require => Package['python-pip'],
  }

  # optional - for kml validation during testing
  package { 'pykml':
    provider => 'pip',
    require => Package['python-lxml'],
  }

  # optional - improves manage.py test
  package { 'django-discover-runner':
    provider => 'pip',
  }

  # put extra packages to install here.

  package { 'fpdf':
    provider => 'pip',
  }
  package { 'qrcode':
    provider => 'pip',
  }
}

class { 'pip_packages': }
Class['ubuntu_packages'] -> Class['pip_packages']

#################################################################
# RUBY GEM PACKAGES

class gem_packages {
  package { 'compass':
    provider => 'gem',
    ensure => '0.12.7',
  }
  package { 'sass':
    provider => 'gem',
  }
  package { 'json':
    provider => 'gem',
  }
  package { 'modular-scale':
   provider => 'gem',
   ensure => '1.0.6'
  }
}

class { 'gem_packages': }
Class['ubuntu_packages'] -> Class['gem_packages']

#################################################################
# NPM PACKAGES

class npm_packages {
  package { 'yuglify':
    provider => 'npm',
  }
  package { 'bower':
    provider => 'npm',
  }
}

class { 'npm_packages': }
Class['ubuntu_packages'] -> Class['npm_packages']

#################################################################
# MYSQL SETUP
# https://forge.puppetlabs.com/puppetlabs/mysql

class mysql_setup {
  # install mysqld server
  class { 'mysql::server':
    package_name => 'mariadb-server-10.0',
    root_password => 'vagrant',
    override_options => {
      'mysqld' => {
        'plugin-load' => 'ha_tokudb',
      }
    }
  }
  contain 'mysql::server'

  # install python bindings
  class { 'mysql::bindings':
  	python_enable => true,
  }
  contain 'mysql::bindings'

  # Install dev packages last so we get right version to match server
  package { 'libmariadbclient-dev': }
}

class { 'mysql_setup': }
Class['mariadb_repo'] -> Class['mysql_setup']

#################################################################
# APACHE SETUP
# https://forge.puppetlabs.com/puppetlabs/apache

class apache_setup {
  anchor { 'apache_setup::begin':
    before => [Class['apache'],
               Class['apache::mod::wsgi'],
               ]
  }
  class { 'apache':
    default_vhost => false,
  }
  apache::listen { '80': }
  apache::mod { 'rewrite': }
  class { 'apache::mod::wsgi': }
  anchor { 'apache_setup::end':
    require => [Class['apache'],
                Class['apache::mod::wsgi']],
  }
}

class { 'apache_setup': }
Class['ubuntu_packages'] -> Class['apache_setup']

######################################################################
# SITE SETUP

if $dev_instance {
  $apacheConfSource = "${deploy}/etc/xgds_${site}_dev.conf"
}
else {
  $apacheConfSource = "${deploy}/etc/xgds_${site}_prod.conf"
}

class site_setup {
  # make symlinks to the apache site config in the standard locations so
  # apache uses it.
  file { 'apache2_conf_available':
    path => "/etc/apache2/sites-available/xgds_${site}.conf",
    ensure => file,
    content => file($apacheConfSource),
  }
  file { 'apache2_conf_enabled':
    path => "/etc/apache2/sites-enabled/xgds_${site}.conf",
    ensure => link,
    target => "../sites-available/xgds_${site}.conf",
    require => File['apache2_conf_available'],
  }
  # pyraptord boot script
#  file { 'pyraptord_conf':
#    path => '/etc/init/pyraptord.conf',
#    source => "${sitedir}/management/bootscripts/pyraptord.conf",
#  }

  # run 'manage.py bootstrap' to generate sourceme.sh and settings.py
  exec { 'bootstrap':
    command => "${sitedir}/management/bootstrap.py --puppet --yes genSourceme genSettings",
    onlyif => '/usr/bin/test ! -f ${sitedir}/settings.py',
    creates => "${sitedir}/settings.py",
    user => $user,
  }
  
  # append vagrant-specific settings to base settings.py
  exec { 'extraSettings':
    command => "/bin/cat ${deploy}/etc/extraSettings.py >> ${sitedir}/settings.py && touch ${sitedir}/build/management/extraSettings.txt",
    creates => "${sitedir}/build/management/extraSettings.txt",
    require => Exec['bootstrap'],
  }

  class dbcreate {
    mysql::db { "xgds_${site}":
      ensure => present,
      user => $user,
      password => 'vagrant',
      charset => 'utf8',
      collate => 'utf8_general_ci',
    }
  }
  class { 'dbcreate': }
  contain 'dbcreate'

#  exec { 'dbfetch':
#    command => "/usr/bin/curl -o /home/$user/puppet/xgds_${site}_dump.sql.gz http://xgds.org/vagrant/xgds_${site}_dump.sql.gz",
#    creates => "/home/$user/puppet/xgds_${site}_dump.sql.gz",
#    user => $user,
#  }

#  exec { 'dbrestore':
#    command => "/bin/gunzip -c /home/$user/puppet/xgds_${site}_dump.sql.gz | ${sitedir}/manage.py dbshell",
#    creates => "/var/lib/mysql/xgds_${site}/auth_user.frm",
#    require => [Class['dbcreate'], Exec['extraSettings'], Exec['dbfetch']],
#    user => $user,
#  }

#  exec { 'datafetch':
#    command => "/usr/bin/curl -o /home/$user/puppet/xgds_${site}_data_dir.tgz http://xgds.org/vagrant/xgds_${site}_data_dir.tgz",
#    creates => "/home/$user/puppet/xgds_${site}_data_dir.tgz",
#    user => $user,
#  }

#  exec { 'data_dir_unpack':
#    command => "/bin/tar xfz /home/$user/puppet/xgds_${site}_data_dir.tgz && chmod -R a+rX xgds_${site}_data && chmod -R g+w xgds_${site}_data && find xgds_${site}_data -type d | xargs chmod g+s && sudo chown -R www-data:www-data xgds_${site}_data && mv xgds_${site}_data xgds_${site}/data",
#    cwd => "/home/$user/gds/",
#    creates => "${sitedir}/data",
#    require => Exec['datafetch'],
#  }

  user { $user:
    ensure => present,
    # uid => 1001,
    # gid => 1001,
    groups => ['www-data'],
  }

  exec { 'prep':
    # can't run this with root environment variables, because bower
    # crashes if it looks for files in root's home directory. setting the puppet
    # 'user' flag as shown below isn't sufficient. 'su' seems to be needed.
    command => "/bin/su -l $user -c '(cd gds/xgds_basalt && ./manage.py prep)'",
    require => Exec['bootstrap'],
  }

  # symlink shortcut
  file { "/home/$user/xgds_${site}":
    ensure => link,
    target => "gds/xgds_${site}",
  }

  # handy setup for dev work
  exec { 'bashrc_extras':
    command => "/bin/cat ${deploy}/etc/bashrc_extras.sh >> /home/$user/.bashrc && touch /home/$user/.installed_bashrc_extras",
    creates => "/home/$user/.installed_bashrc_extras",
  }
  file { "/home/$user/.screenrc":
    source => "${deploy}/etc/screenrc",
  }
  file { "/home/$user/.emacs":
    source => "${deploy}/etc/emacs",
  }
  file { "/usr/local/bin/pcache":
    source => "${deploy}/etc/pcache",
  }
  exec { "ensure_gitconfig":
    # if etc/gitconfig is not present, create as an empty file to avoid error.
    command => "/usr/bin/touch ${deploy}/etc/gitconfig",
    creates => "${deploy}/etc/gitconfig",
  }
  file { "/home/$user/.gitconfig":
    source => "${deploy}/etc/gitconfig",
    require => Exec['ensure_gitconfig'],
  }
}

class { 'site_setup':
  require => [Class['pip_packages'],
              Class['mysql_setup'],
              Class['apache_setup'],
	     ],
  notify => Service['apache2'],
}
Class['apache_setup'] -> Class['site_setup']
