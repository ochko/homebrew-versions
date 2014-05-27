require 'formula'

class Gsl114 < Formula
  homepage 'http://www.gnu.org/software/gsl/'
  url 'http://ftpmirror.gnu.org/gsl/gsl-1.14.tar.gz'
  mirror 'http://ftp.gnu.org/gnu/gsl/gsl-1.14.tar.gz'
  sha1 'e1a600e4fe359692e6f0e28b7e12a96681efbe52'

  option :universal

  def install
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make" # "make" and "make install" _must_ be done separately
    system "make install"
  end
end

