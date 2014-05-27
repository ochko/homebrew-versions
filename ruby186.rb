require 'formula'

class Ruby186 < Formula
  homepage 'http://www.ruby-lang.org/en/'
  url 'http://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.6-p420.tar.bz2'
  mirror 'http://mirrorservice.org/sites/ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.6-p420.tar.bz2'
  sha256 '5ed3e6b9ebcb51baf59b8263788ec9ec8a65fbb82286d952dd3eb66e22d9a09f'

  # Otherwise it fails when building bigdecimal by trying to load
  # files from the system ruby instead of the one it's building
  env :std

  keg_only :provided_by_osx

  option :universal
  option 'with-suffix', 'Suffix commands with "20"'
  option 'with-doc', 'Install documentation'
  option 'with-tcltk', 'Install with Tcl/Tk support'

  depends_on 'pkg-config' => :build
  depends_on 'readline' => :recommended
  depends_on 'gdbm' => :optional
  depends_on 'libyaml'
  depends_on 'openssl' if MacOS.version >= :mountain_lion
  depends_on :x11 if build.with? 'tcltk'

  fails_with :llvm do
    build 2326
  end

  # First patch backports a compatibility fix from Ruby 1.8.7 for newer OpenSSL versions
  # Second patch fixes the type of a macro, also taken from 1.8.7
  def patches; DATA; end

  def install
    args = %W[--prefix=#{prefix} --enable-shared]
    args << "--program-suffix=20" if build.with? "suffix"
    args << "--with-arch=#{Hardware::CPU.universal_archs.join(',')}" if build.universal?
    args << "--with-out-ext=tk" if build.without? "tcltk"
    args << "--disable-install-doc" if build.without? "doc"
    args << "--disable-dtrace" unless MacOS::CLT.installed?

    # OpenSSL is deprecated on OS X 10.8 and Ruby can't find the outdated
    # version (0.9.8r 8 Feb 2011) that ships with the system.
    # See discussion https://github.com/sstephenson/ruby-build/issues/304
    # and https://github.com/mxcl/homebrew/pull/18054
    if MacOS.version >= :mountain_lion
      args << "--with-openssl-dir=#{Formula["openssl"].opt_prefix}"
    end

    # Put gem, site and vendor folders in the HOMEBREW_PREFIX
    ruby_lib = HOMEBREW_PREFIX/"lib/ruby"
    (ruby_lib/'site_ruby').mkpath
    (ruby_lib/'vendor_ruby').mkpath
    (ruby_lib/'gems').mkpath

    (lib/'ruby').install_symlink ruby_lib/'site_ruby',
                                 ruby_lib/'vendor_ruby',
                                 ruby_lib/'gems'

    system "./configure", *args
    system "make"
    system "make install"
  end

  def caveats; <<-EOS.undent
    NOTE: By default, gem installed binaries will be placed into:
      #{opt_prefix}/bin

    You may want to add this to your PATH.
    EOS
  end
end

__END__
diff --git a/ext/openssl/ossl.h b/ext/openssl/ossl.h
index 8dfd8da..25a62bc 100644
--- a/ext/openssl/ossl.h
+++ b/ext/openssl/ossl.h
@@ -107,6 +107,13 @@ extern VALUE eOSSLError;
 } while (0)
 
 /*
+* Compatibility
+*/
+#if OPENSSL_VERSION_NUMBER >= 0x10000000L
+#define STACK _STACK
+#endif
+
+/*
  * String to HEXString conversion
  */
 int string2hex(char *, int, char **, int *);

diff --git a/ext/openssl/ossl.c b/ext/openssl/ossl.c
index 1b8f76a..73fdd03 100644
--- a/ext/openssl/ossl.c
+++ b/ext/openssl/ossl.c
@@ -92,7 +92,7 @@ ossl_x509_ary2sk(VALUE ary)
 
 #define OSSL_IMPL_SK2ARY(name, type)	        \
 VALUE						\
-ossl_##name##_sk2ary(STACK *sk)			\
+ossl_##name##_sk2ary(STACK_OF(type) *sk)			\
 {						\
     type *t;					\
     int i, num;					\
