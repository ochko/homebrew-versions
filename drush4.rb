require 'formula'

class Drush4 < Formula
  homepage 'https://github.com/drush-ops/drush'
  url 'http://ftp.drupal.org/files/projects/drush-7.x-4.6.tar.gz'
  sha1 '51d7a7743342cb3dabb201b4c5433ab3da06fb40'

  keg_only "Conflicts with drush in main repository."

  def install
    libexec.install Dir['*']
    bin.install_symlink libexec+'drush'
  end
end
