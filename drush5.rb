require 'formula'

class Drush5 < Formula
  homepage 'https://github.com/drush-ops/drush'
  url 'http://ftp.drupal.org/files/projects/drush-7.x-5.9.tar.gz'
  sha1 '12533dbc7a18f1fef79a1853a8fdb88171f4fed8'

  keg_only "Conflicts with drush in main repository."

  def install
    libexec.install Dir['*']
    bin.install_symlink libexec+'drush'
  end
end
