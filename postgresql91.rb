class Postgresql91 < Formula
  desc "Object-relational database system"
  homepage "http://www.postgresql.org/"
  url "http://ftp.postgresql.org/pub/source/v9.1.18/postgresql-9.1.18.tar.bz2"
  sha256 "2726d526666904b454f87fe2ae54357c2ab9eb8aba299a4c904829b7598584a8"

  bottle do
    sha256 "b835973c64ac96c1e6c2f3e32df0f920381c9533ffb369359c6bffa7f1a3f076" => :yosemite
    sha256 "711c837ee84a78f6627548ae94e7d4857e8f453de93ca92806227fa2fd50cc83" => :mavericks
    sha256 "ede5b6a722f9c46f4001cb07d88134db5cea08cfd8daeb611558820cb53ae7ab" => :mountain_lion
  end

  option "32-bit"
  option "without-python", "Build without Python support"
  option "without-perl", "Build without Perl support"
  option "without-tcl", "Build without Tcl support"
  option "with-dtrace", "Build with DTrace support"

  deprecated_option "no-python" => "without-python"
  deprecated_option "no-perl" => "without-perl"
  deprecated_option "no-tcl" => "without-tcl"
  deprecated_option "enable-dtrace" => "with-dtrace"

  depends_on "openssl"
  depends_on "readline"
  depends_on "libxml2" if MacOS.version == :leopard
  depends_on "ossp-uuid" => :recommended

  # Fix uuid-ossp build issues: http://archives.postgresql.org/pgsql-general/2012-07/msg00654.php
  patch :DATA

  def install
    ENV.libxml2 if MacOS.version >= :snow_leopard

    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --datadir=#{share}/#{name}
      --docdir=#{doc}
      --enable-thread-safety
      --with-bonjour
      --with-gssapi
      --with-krb5
      --with-openssl
      --with-libxml
      --with-libxslt
    ]

    args << "--with-ossp-uuid" if build.with? "ossp-uuid"
    args << "--with-python" if build.with? "python"
    args << "--with-perl" if build.with? "perl"

    # The CLT is required to build tcl support on 10.7 and 10.8 because tclConfig.sh is not part of the SDK
    if build.with?("tcl") && (MacOS.version >= :mavericks || MacOS::CLT.installed?)
      args << "--with-tcl"

      if File.exist?("#{MacOS.sdk_path}/usr/lib/tclConfig.sh")
        args << "--with-tclconfig=#{MacOS.sdk_path}/usr/lib"
      end
    end

    args << "--enable-dtrace" if build.with? "dtrace"

    if build.with? "ossp-uuid"
      ENV.append "CFLAGS", `uuid-config --cflags`.strip
      ENV.append "LDFLAGS", `uuid-config --ldflags`.strip
      ENV.append "LIBS", `uuid-config --libs`.strip
    end

    if !build.build_32_bit? && MacOS.prefer_64_bit? && build.with?("python")
      args << "ARCHFLAGS='-arch x86_64'"
      check_python_arch
    end

    if build.build_32_bit?
      ENV.append "CFLAGS", "-arch i386"
      ENV.append "LDFLAGS", "-arch i386"
    end

    system "./configure", *args
    system "make", "install-world"
  end

  def check_python_arch
    # On 64-bit systems, we need to look for a 32-bit Framework Python.
    # The configure script prefers this Python version, and if it doesn't
    # have 64-bit support then linking will fail.
    framework_python = Pathname.new "/Library/Frameworks/Python.framework/Versions/Current/Python"
    return unless framework_python.exist?
    unless (archs_for_command framework_python).include? :x86_64
      opoo "Detected a framework Python that does not have 64-bit support in:"
      puts <<-EOS.undent
          #{framework_python}

        The configure script seems to prefer this version of Python over any others,
        so you may experience linker problems as described in:
          http://osdir.com/ml/pgsql-general/2009-09/msg00160.html

        To fix this issue, you may need to either delete the version of Python
        shown above, or move it out of the way before brewing PostgreSQL.

        Note that a framework Python in /Library/Frameworks/Python.framework is
        the "MacPython" version, and not the system-provided version which is in:
          /System/Library/Frameworks/Python.framework
      EOS
    end
  end

  def caveats
    s = <<-EOS
      # Build Notes

      If builds of PostgreSQL 9 are failing and you have version 8.x installed,
      you may need to remove the previous version first. See:
        https://github.com/mxcl/homebrew/issues/issue/2510

      To build plpython against a specific Python, set PYTHON prior to brewing:
        PYTHON=/usr/local/bin/python  brew install postgresql
      See:
        http://www.postgresql.org/docs/9.1/static/install-procedure.html

      # Create/Upgrade a Database

      If this is your first install, create a database with:
        initdb #{var}/postgres -E utf8

      To migrate existing data from a previous major version (pre-9.1) of PostgreSQL, see:
        http://www.postgresql.org/docs/9.1/static/upgrading.html

      # Loading Extensions

      By default, Homebrew builds all available Contrib extensions.  To see a list of all
      available extensions, from the psql command line, run:
        SELECT * FROM pg_available_extensions;

      To load any of the extension names, navigate to the desired database and run:
        CREATE EXTENSION [extension name];

      For instance, to load the tablefunc extension in the current database, run:
        CREATE EXTENSION tablefunc;

      For more information on the CREATE EXTENSION command, see:
        http://www.postgresql.org/docs/9.1/static/sql-createextension.html
      For more information on extensions, see:
        http://www.postgresql.org/docs/9.1/static/contrib.html

      # Other

      Some machines may require provisioning of shared memory:
        http://www.postgresql.org/docs/current/static/kernel-resources.html#SYSVIPC
    EOS

    if MacOS.prefer_64_bit?
      s << "\n" << <<-EOS.undent
        When installing the postgres gem, including ARCHFLAGS is recommended:
          ARCHFLAGS="-arch x86_64" gem install pg

        To install gems without sudo, see the Homebrew wiki.
      EOS
    end
    s
  end

  plist_options :manual => "pg_ctl -D #{HOMEBREW_PREFIX}/var/postgres -l #{HOMEBREW_PREFIX}/var/postgres/server.log start"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_prefix}/bin/postgres</string>
        <string>-D</string>
        <string>#{var}/postgres</string>
        <string>-r</string>
        <string>#{var}/postgres/server.log</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/initdb", testpath/"test"
  end
end


__END__
--- a/contrib/uuid-ossp/uuid-ossp.c	2012-07-30 18:34:53.000000000 -0700
+++ b/contrib/uuid-ossp/uuid-ossp.c	2012-07-30 18:35:03.000000000 -0700
@@ -9,6 +9,8 @@
  *-------------------------------------------------------------------------
  */

+#define _XOPEN_SOURCE
+
 #include "postgres.h"
 #include "fmgr.h"
 #include "utils/builtins.h"
