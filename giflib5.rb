require 'formula'

class Giflib5 < Formula
  homepage 'http://giflib.sourceforge.net/'
  url 'https://downloads.sourceforge.net/project/giflib/giflib-5.x/giflib-5.0.5.tar.bz2'
  sha1 '926fecbcef1c5b1ca9d17257d15a197b8b35e405'

  keg_only "Conflicts with giflib in main repository."

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make install"
  end
end
