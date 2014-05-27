require 'formula'

class Glfw2 < Formula
  homepage 'http://www.glfw.org/'
  url 'https://downloads.sourceforge.net/project/glfw/glfw/2.7.9/glfw-2.7.9.tar.bz2'
  sha1 '50ffcbfa1fb47d23aa6ad1245da329bd21bbaeca'

  option :universal

  def install
    ENV.universal_binary if build.universal?
    system 'make', "PREFIX=#{prefix}", 'cocoa-dist-install'
  end
end
