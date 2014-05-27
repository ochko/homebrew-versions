require 'formula'

class Allegro5 < Formula
  homepage 'http://www.allegro.cc'
  url 'https://downloads.sourceforge.net/project/alleg/allegro/5.0.9/allegro-5.0.9.tar.gz'
  sha1 '7d05bc3d59b60a22796e9938f0b9a463c33d4b30'

  head 'git://git.code.sf.net/p/alleg/allegro', :branch => '5.1'

  depends_on 'cmake' => :build
  depends_on 'libvorbis' => :optional
  depends_on 'freetype' => :optional
  depends_on 'flac' => :optional
  depends_on 'libpng' => :optional
  depends_on 'jpeg' => :optional
  depends_on 'physfs' => :optional

  def install
    system "cmake", ".", *std_cmake_args
    system "make install"
  end
end
