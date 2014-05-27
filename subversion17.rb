require 'formula'

class Subversion17 < Formula
  homepage 'http://subversion.apache.org/'
  url 'http://mirror.cogentco.com/pub/apache/subversion/subversion-1.7.14.tar.bz2'
  mirror 'http://archive.apache.org/dist/subversion/subversion-1.7.14.tar.bz2'
  sha1 'b35254a844d0b221a3fd8e80974ac75119d77b94'

  option :universal
  option 'java', 'Build Java bindings'
  option 'perl', 'Build Perl bindings'
  option 'ruby', 'Build Ruby bindings'
  option 'unicode-path', 'Include support for OS X UTF-8-MAC filename'

  resource 'serf' do
    url 'http://serf.googlecode.com/files/serf-1.3.3.tar.bz2'
    sha1 'b25c44a8651805f20f66dcaa76db08442ec4fa0e'
  end

  depends_on 'pkg-config' => :build

  # Always build against Homebrew versions instead of system versions for consistency.
  depends_on 'neon'
  depends_on 'sqlite'
  depends_on :python => :optional
  depends_on 'openssl'

  # Building Ruby bindings requires libtool
  depends_on 'libtool' => :build if build.include? 'ruby'

  # For Serf
  depends_on 'scons' => :build

  # If building bindings, allow non-system interpreters
  env :userpaths if (build.include? 'perl') or (build.include? 'ruby')

  def patches
    ps = []

    # Patch for Subversion handling of OS X UTF-8-MAC filename.
    if build.include? 'unicode-path'
      ps << "https://gist.github.com/jeffstyr/3044094/raw/1648c28f6133bcbb68b76b42669b0dc237c02dba/patch-path.c.diff"
    end

    # Patch to prevent '-arch ppc' from being pulled in from Perl's $Config{ccflags}
    if build.include? 'perl'
      ps << DATA
    end

    unless ps.empty?
      { :p0 => ps }
    end
  end

  # When building Perl or Ruby bindings, need to use a compiler that
  # recognizes GCC-style switches, since that's what the system languages
  # were compiled against.
  fails_with :clang do
    build 318
    cause "core.c:1: error: bad value (native) for -march= switch"
  end if (build.include? 'perl') or (build.include? 'ruby')

  def install
    serf_prefix = libexec+'serf'

    resource('serf').stage do
      # SConstruct merges in gssapi linkflags using scons's MergeFlags,
      # but that discards duplicate values - including the duplicate
      # values we want, like multiple -arch values for a universal build.
      # Passing 0 as the `unique` kwarg turns this behaviour off.
      inreplace 'SConstruct', 'unique=1', 'unique=0'

      ENV.universal_binary if build.universal?
      # scons ignores our compiler and flags unless explicitly passed
      args = %W[PREFIX=#{serf_prefix} GSSAPI=/usr CC=#{ENV.cc}
                CFLAGS=#{ENV.cflags} LINKFLAGS=#{ENV.ldflags}]
      args << "OPENSSL=#{Formula["openssl"].opt_prefix}"
      scons *args
      scons "install"
    end

    # Java support doesn't build correctly in parallel:
    # https://github.com/mxcl/homebrew/issues/20415
    ENV.deparallelize

    if build.include? 'java'
      unless build.universal?
        opoo "A non-Universal Java build was requested."
        puts "To use Java bindings with various Java IDEs, you might need a universal build:"
        puts "  brew install subversion --universal --java"
      end

      unless (ENV["JAVA_HOME"] or "").empty?
        opoo "JAVA_HOME is set. Try unsetting it if JNI headers cannot be found."
      end
    end

    ENV.universal_binary if build.universal?

    # Use existing system zlib
    # Use dep-provided other libraries
    # Don't mess with Apache modules (since we're not sudo)
    args = ["--disable-debug",
            "--prefix=#{prefix}",
            "--with-apr=#{which("apr-1-config").dirname}",
            "--with-zlib=/usr",
            "--with-sqlite=#{Formula["sqlite"].opt_prefix}",
            "--with-ssl=#{Formula["openssl"].opt_prefix}",
            "--with-serf=#{serf_prefix}",
            "--disable-neon-version-check",
            "--disable-mod-activation",
            "--disable-nls",
            "--without-apache-libexecdir",
            "--without-berkeley-db"]

    args << "--enable-javahl" << "--without-jikes" if build.include? 'java'

    if build.include? 'ruby'
      args << "--with-ruby-sitedir=#{lib}/ruby"
      # Peg to system Ruby
      args << "RUBY=/usr/bin/ruby"
    end

    # The system Python is built with llvm-gcc, so we override this
    # variable to prevent failures due to incompatible CFLAGS
    ENV['ac_cv_python_compile'] = ENV.cc

    system "./configure", *args
    system "make"
    system "make install"
    bash_completion.install 'tools/client-side/bash_completion' => 'subversion'

    system "make tools"
    system "make install-tools"
    %w[
      svn-populate-node-origins-index
      svn-rep-sharing-stats
      svnauthz-validate
      svnmucc
      svnraisetreeconflict
    ].each do |prog|
      bin.install_symlink bin/"svn-tools"/prog
    end

    if build.with? 'python'
      system "make swig-py"
      system "make install-swig-py"
    end

    if build.include? 'perl'
      # Remove hard-coded ppc target, add appropriate ones
      if build.universal?
        arches = "-arch x86_64 -arch i386"
      elsif MacOS.version == :leopard
        arches = "-arch i386"
      else
        arches = "-arch x86_64"
      end

      perl_core = Pathname.new(`perl -MConfig -e 'print $Config{archlib}'`)+'CORE'
      unless perl_core.exist?
        onoe "perl CORE directory does not exist in '#{perl_core}'"
      end

      inreplace "Makefile" do |s|
        s.change_make_var! "SWIG_PL_INCLUDES",
          "$(SWIG_INCLUDES) #{arches} -g -pipe -fno-common -DPERL_DARWIN -fno-strict-aliasing -I/usr/local/include -I#{perl_core}"
      end
      system "make swig-pl"
      system "make", "install-swig-pl", "DESTDIR=#{prefix}"
      lib.install_symlink Dir["#{prefix}/#{lib}/*"]
      man3.install_symlink Dir["#{prefix}/#{HOMEBREW_PREFIX}/share/man/man3/*"]
    end

    if build.include? 'java'
      system "make javahl"
      system "make install-javahl"
    end

    if build.include? 'ruby'
      # Peg to system Ruby
      system "make swig-rb EXTRA_SWIG_LDFLAGS=-L/usr/lib"
      system "make install-swig-rb"
    end
  end

  def caveats
    s = ""

    if build.include? 'perl'
      s += <<-EOS.undent
        The perl bindings are located in various subdirectories of:
          #{prefix}/Library/Perl

      EOS
    end

    if build.include? 'ruby'
      s += <<-EOS.undent
        You may need to add the Ruby bindings to your RUBYLIB from:
          #{HOMEBREW_PREFIX}/lib/ruby

      EOS
    end

    if build.include? 'java'
      s += <<-EOS.undent
        You may need to link the Java bindings into the Java Extensions folder:
          sudo mkdir -p /Library/Java/Extensions
          sudo ln -s #{HOMEBREW_PREFIX}/lib/libsvnjavahl-1.dylib /Library/Java/Extensions/libsvnjavahl-1.dylib

      EOS
    end

    if build.include? 'unicode-path'
      s += <<-EOS.undent
        This unicode-path version implements a hack to deal with composed/decomposed
        unicode handling on Mac OS X which is different from linux and windows.
        It is an implementation of solution 1 from
        http://svn.collab.net/repos/svn/trunk/notes/unicode-composition-for-filenames
        which _WILL_ break some setups. Please be sure you understand what you
        are asking for when you install this version.

      EOS
    end

    return s.empty? ? nil : s
  end
end

__END__
--- subversion/bindings/swig/perl/native/Makefile.PL.in~	2011-07-16 04:47:59.000000000 -0700
+++ subversion/bindings/swig/perl/native/Makefile.PL.in	2012-06-27 17:45:57.000000000 -0700
@@ -57,10 +57,13 @@
 
 chomp $apr_shlib_path_var;
 
+my $config_ccflags = $Config{ccflags};
+$config_ccflags =~ s/-arch\s+\S+//g; # remove any -arch arguments, since the ones we want will already be in $cflags
+
 my %config = (
     ABSTRACT => 'Perl bindings for Subversion',
     DEFINE => $cppflags,
-    CCFLAGS => join(' ', $cflags, $Config{ccflags}),
+    CCFLAGS => join(' ', $cflags, $config_ccflags),
     INC  => join(' ',$apr_cflags, $apu_cflags,
                  " -I$swig_srcdir/perl/libsvn_swig_perl",
                  " -I$svnlib_srcdir/include",
