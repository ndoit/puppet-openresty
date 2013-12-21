# installs the lua-enabled nginx variant "openresty"
# requires a $user to be set by the caller for editing the path in bashrc
class openresty {

  # user must be set (for setting up path)G
  if $user == undef { fail("'user' not defined") }

  # openresty environment variables
  $openresty_package_url = "https://s3.amazonaws.com/OpenRestyPackage/ngx_openresty-1.2.8.6.tar.tar.tar.gz"
  
  $openresty_home = "usr/local/openresty"
  $openresty_src = "${openresty_home}/src"
  $openresty_filename = "ngx_openresty-1.2.8.6"
  $targz_suffix = ".tar.gz"

  Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
  ->
  package {'readline-devel':
	ensure =>	latest,
	provider =>	yum
  }
  ->
  package {'pcre-devel':
	ensure =>	latest,
	provider =>	yum
  }
  ->
  package {'openssl-devel':
	ensure =>	latest,
	provider =>	yum
  }
  ->
  package {'perl':
	ensure =>	installed,
	provider =>	yum
  }
  ->
  package {'make':
	ensure =>	installed,
	provider =>	yum
  }
  ->
  file {"openresty install dir":
	ensure =>	directory,
  	path => 	"${openresty_home}",
	mode =>		"0755",
	owner =>	$user
  }
  ->	
  file {"openresty install dir src":
	ensure =>	directory,
  	path => 	"${openresty_src}",
	mode =>		"0755",
	owner =>	$user
  }
  ->	
  exec { 'download package':
        command => "wget ${openresty_package_url} -O ${openresty_src}/${openresty_filename}${targz_suffix}",
        creates => "${openresty_src}/${openresty_filename}${targz_suffix}"
  }
  ->
  file {"${openresty_filename}${targz_suffix}":
	ensure =>	file,
	path => 	"${openresty_src}/${openresty_filename}${targz_suffix}",
	source => 	"${openresty_src}/${openresty_filename}${targz_suffix}",
	mode => 	"0755",
	owner => 	$user
  }
  ->
  exec {"tar -xzf ${openresty_filename}${targz_suffix}":
	user => 	$user,
	cwd =>		$openresty_src
  }
  ->
  exec {"${openresty_src}/${openresty_filename}/configure --with-luajit":
	cwd =>		"${openresty_src}/${openresty_filename}",
	user =>		$user
  }
  ->
  exec {"make -j2":
	cwd =>		"${openresty_src}/${openresty_filename}",
	user =>		$user
  }
  ->
  exec {"make install":
	cwd =>		"${openresty_src}/${openresty_filename}"
  }
  ->
  # ENVIRONMENTAL SETTINGS
  exec {"bash -c 'echo \"export PATH=\\\$PATH:${openresty_home}/bin\" >> /home/${user}/.bashrc'":
	user => 	$user
  }
  
}
