require 'formula'

class Cvsps2 < Formula
  homepage 'http://www.catb.org/~esr/cvsps/'
  url 'http://www.cobite.com/cvsps/cvsps-2.1.tar.gz'
  sha1 'a53a62b121e7b86e07a393bcb8aa4f0492a747c4'

  def install
    system "make", "all"
    system "make", "install", "prefix=#{prefix}"
  end
end
