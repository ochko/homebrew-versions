require 'formula'

class Gawk3 < Formula
  homepage 'http://www.gnu.org/software/gawk/'
  url 'http://ftpmirror.gnu.org/gawk/gawk-3.1.8.tar.bz2'
  mirror 'http://ftp.gnu.org/gnu/gawk/gawk-3.1.8.tar.bz2'
  sha1 'da1091cc39089c320f53d21fd2112bd7ce407de5'

  fails_with :llvm do
    build 2326
    cause "Undefined symbols when linking"
  end

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make install"
  end
end
