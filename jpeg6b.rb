require 'formula'

class Jpeg6b < Formula
  homepage 'http://www.ijg.org'
  url 'http://www.ijg.org/files/jpegsrc.v6b.tar.gz'
  sha1 '7079f0d6c42fad0cfba382cf6ad322add1ace8f9'

  depends_on 'libtool' => :build

  def install
    bin.mkpath
    lib.mkpath
    include.mkpath
    man1.mkpath

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-shared"

    system "make", "install",
                   "install-lib",
                   "install-headers",
                   "mandir=#{man1}",
                   "LIBTOOL=glibtool"
  end
end
