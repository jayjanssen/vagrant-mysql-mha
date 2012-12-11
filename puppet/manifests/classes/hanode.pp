class hanode {
  package { ["mysql-server", "mysql-client", "libdbd-mysql-perl"]:
    ensure => present,
  }

  file { "/etc/mysql/conf.d/mha.cnf":
    require => Package["mysql-server"],
    content => "[mysqld]\nlog-bin\nbind=0.0.0.0\nread-only\nrelay_log_purge=0",
    ensure  => "present",
    owner   => "mysql",
    group   => "mysql", 
    notify  => Service["mysql"],
  }

  package { "mha4mysql-node":
    require => [Package["libdbd-mysql-perl"],Exec["download-node-package"]],
    ensure => present,
    provider => dpkg,
    source => "/vagrant/puppet/files/packages/mha4mysql-node_0.54-0_all.deb",
  }

  exec { "download-node-package":
    command => "/vagrant/puppet/files/packages/download-packages.sh",
    user    => "root",
    cwd     => "/vagrant/puppet/files/packages",
    creates => "/vagrant/puppet/files/packages/mha4mysql-node_0.54-0_all.deb",
  }  

  service { "mysql":
    ensure => "running", require => [Package['mysql-server']];
  }

  exec { "root4all":
    require => [Service["mysql"],Package["mysql-client"]],
    command => "/usr/bin/mysql -u root -e\"GRANT ALL ON *.* TO 'root'@'%';\"",
    unless => "/usr/bin/mysql -u root -e\"SELECT User FROM mysql.user Where User='root' AND Host='%';\" | grep -q root",
  }

	file { "/etc/app1.cnf":
	  source => "/vagrant/puppet/files/mha/app1.cnf",
	  mode => 644,
	  owner => "root",
	}
}

