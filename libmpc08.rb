require 'formula'

class Libmpc08 < Formula
  homepage 'http://multiprecision.org'
  # Track gcc infrastructure releases.
  url 'http://multiprecision.org/mpc/download/mpc-0.8.1.tar.gz'
  mirror 'ftp://gcc.gnu.org/pub/gcc/infrastructure/mpc-0.8.1.tar.gz'
  sha1 '5ef03ca7aee134fe7dfecb6c9d048799f0810278'

  bottle do
    sha1 '7f63cdd281274f82122d7580400a4b5561dabd93' => :tiger_g3
    sha1 'fa73d69bf25ccfe069dc553a4d90f09877ca9054' => :tiger_altivec
    sha1 'bc3ce1df9d7afcafa05f270e03ac73158c312004' => :leopard_g3
    sha1 'a9905224e99541da96d4c1c6fec7276bf6eb1404' => :leopard_altivec
  end

  keg_only 'Conflicts with libmpc in main repository.'

  depends_on 'gmp4'
  depends_on 'mpfr2'

  def install
    args = [
      "--prefix=#{prefix}",
      "--disable-dependency-tracking",
      "--with-gmp=#{Formula["gmp4"].opt_prefix}",
      "--with-mpfr=#{Formula["mpfr2"].opt_prefix}"
    ]

    system "./configure", *args
    system "make"
    system "make check"
    system "make install"
  end
end
