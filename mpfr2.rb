require 'formula'

class Mpfr2 < Formula
  homepage 'http://www.mpfr.org/'
  # Track gcc infrastructure releases.
  url 'http://www.mpfr.org/mpfr-2.4.2/mpfr-2.4.2.tar.bz2'
  mirror 'ftp://gcc.gnu.org/pub/gcc/infrastructure/mpfr-2.4.2.tar.bz2'
  sha1 '7ca93006e38ae6e53a995af836173cf10ee7c18c'

  bottle do
    sha1 'd146a7ec89d73a64906ed3fa930d1062b0cb5479' => :tiger_g3
    sha1 '87ea4788e631dd447a92e78cc183093ecf4157be' => :tiger_altivec
    sha1 '6ffec69dca10ac3cb40a6dc7d1221200eb7d888a' => :leopard_g3
    sha1 '39c667af86e969336c904afb55ad7b25f81a4140' => :leopard_altivec
  end

  depends_on 'gmp4'

  keg_only 'Conflicts with mpfr in main repository.'

  option '32-bit'

  fails_with :clang do
    build 421
    cause <<-EOS.undent
      clang build 421 segfaults while building in superenv;
      see https://github.com/mxcl/homebrew/issues/15061
      EOS
  end

  def install
    gmp4 = Formula["gmp4"]

    args = [
      "--disable-dependency-tracking",
      "--prefix=#{prefix}",
      "--with-gmp=#{gmp4.opt_prefix}"
    ]

    # Build 32-bit where appropriate, and help configure find 64-bit CPUs
    # Note: This logic should match what the GMP formula does.
    if MacOS.prefer_64_bit? and not build.build_32_bit?
      ENV.m64
      args << "--build=x86_64-apple-darwin"
    else
      ENV.m32
      args << "--build=none-apple-darwin"
    end

    system "./configure", *args
    system "make"
    system "make check"
    system "make install"
  end
end
