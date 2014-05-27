require 'formula'

class Isl011 < Formula
  homepage 'http://freecode.com/projects/isl'
  # Track gcc infrastructure releases.
  url 'http://isl.gforge.inria.fr/isl-0.11.1.tar.bz2'
  mirror 'ftp://gcc.gnu.org/pub/gcc/infrastructure/isl-0.11.1.tar.bz2'
  sha1 'd7936929c3937e03f09b64c3c54e49422fa8ddb3'

  bottle do
    sha1 '49d0c81d3d0e72abe18e171b58e6159122ba07bc' => :tiger_g3
    sha1 '7500d4495c2da2059b484d96190d8e563b01a357' => :tiger_altivec
    sha1 '5cf2a19ddde50e65786a2d5957a0d0b20f1db94c' => :leopard_g3
    sha1 '3c97c65cdacf43c0f310309a9b5f0a242fd7b925' => :leopard_altivec
  end

  keg_only 'Conflicts with isl in main repository.'

  depends_on 'gmp4'

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--with-gmp=system",
                          "--with-gmp-prefix=#{Formula["gmp4"].opt_prefix}"
    system "make install"
    (share/"gdb/auto-load").install Dir["#{lib}/*-gdb.py"]
  end
end
