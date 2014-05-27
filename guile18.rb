require 'formula'

class Guile18 < Formula
  homepage 'http://www.gnu.org/software/guile/'
  url 'http://ftpmirror.gnu.org/guile/guile-1.8.8.tar.gz'
  mirror 'http://ftp.gnu.org/gnu/guile/guile-1.8.8.tar.gz'
  sha1 '548d6927aeda332b117f8fc5e4e82c39a05704f9'

  depends_on 'pkg-config' => :build
  depends_on 'libtool' => :run
  depends_on 'libffi'
  depends_on 'libunistring'
  depends_on 'bdw-gc'
  depends_on 'gmp'
  depends_on 'readline'

  fails_with :llvm do
    build 2336
    cause "Segfaults during compilation"
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-libreadline-prefix=#{Formula["readline"].opt_prefix}"
    system "make install"

    # A really messed up workaround required on OS X --mkhl
    Pathname.glob("#{lib}/*.dylib") do |dylib|
      lib.install_symlink dylib.basename => "#{dylib.basename(".dylib")}.so"
    end
  end
end
