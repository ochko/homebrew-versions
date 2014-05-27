require 'formula'

class Log4cplus10 < Formula
  url 'https://downloads.sourceforge.net/project/log4cplus/log4cplus-stable/1.0.4/log4cplus-1.0.4.3.tar.bz2'
  homepage 'http://log4cplus.sourceforge.net/'
  sha1 '917d244f7f3d58a5fff35e3eef7fff9c74e9409b'

  keg_only "so it can live alongside current version of log4cplus"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make install"
  end
end
