# == Class pulp::repos
#
# This class is called from pulp for repository management.
#
class pulp::repos {

  if $pulp::manage_repo {
    yumrepo { "pulp-${pulp::version}-stable":
      ensure   => present,
      descr    => "Pulp ${pulp::version} Production Releases",
      baseurl  => "https://repos.fedorapeople.org/repos/pulp/pulp/stable/${pulp::version}/\$releasever/\$basearch/",
      enabled  => 1,
      gpgcheck => 1,
      gpgkey   => 'https://repos.fedorapeople.org/repos/pulp/pulp/GPG-RPM-KEY-pulp-2',
      proxy    => $::pulp::repo_proxy,
    }
  } else {
    notice('Pulp repo management disabled...skipping repo management')
  }

}
