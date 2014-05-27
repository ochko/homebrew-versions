require 'formula'

class Allegro4 < Formula
  homepage 'http://www.allegro.cc'
  url 'https://downloads.sourceforge.net/project/alleg/allegro/4.4.1.1/allegro-4.4.1.1.tar.gz'
  sha1 '1970570b54c4329c7bd6d103db01624c68f2e9be'

  depends_on 'cmake' => :build
  depends_on 'libvorbis' => :optional

  def install
    system "cmake", ".", *std_cmake_args
    system "make install"
  end
end
