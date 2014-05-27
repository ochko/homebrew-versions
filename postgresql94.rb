require 'formula'

class Postgresql94 < Formula
  homepage 'http://www.postgresql.org/'
  url 'http://ftp.postgresql.org/pub/source/v9.4beta1/postgresql-9.4beta1.tar.bz2'
  version '9.4beta1'
  sha256 '0e088eff79bb5171b2233222a25d7a2906eaf62aa86266daf6ec5217b1797f47'
  head 'http://git.postgresql.org/git/postgresql.git'

  option '32-bit'
  option 'with-gcc', 'Build with GCC'
  option 'no-perl', 'Build without Perl support'
  option 'no-tcl', 'Build without Tcl support'
  option 'no-krb5', 'Build without Kerberos support'
  option 'no-ldap', 'Build without LDAP support'
  option 'no-xml', 'Build without XML support'
  option 'no-xslt', 'Build without XSLT support'
  option 'no-bonjour', 'Build without Bonjour support'
  option 'no-pam', 'Build without PAM support'
  option 'enable-dtrace', 'Build with DTrace support'

  depends_on 'openssl'
  depends_on 'gettext'
  depends_on 'readline'
  depends_on 'libxml2' => :optional
  depends_on 'ossp-uuid' => :recommended
  depends_on 'python' => :optional

  conflicts_with 'postgres-xc', 'postgresql',
    :because => 'postgresql and postgres-xc install the same binaries.'

  fails_with :clang do
    build 211
    cause 'Miscompilation resulting in segfault on queries'
  end

  def patches
    [
     # Fix uuid-ossp build issues: http://archives.postgresql.org/pgsql-general/2012-07/msg00654.php
     DATA,
     # http://archives.postgresql.org/pgsql-general/2012-07/msg00654.php
     'http://www.postgresql.org/message-id/attachment/32317/configure-uuid.patch',
    ]
  end

  def install
    ENV.libxml2 if MacOS.version >= :snow_leopard && build.with?('libxml2')

    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --datadir=#{share}/#{name}
      --docdir=#{doc}
      --enable-thread-safety
      --with-gssapi
      --with-openssl
    ]

    args << "--with-ossp-uuid" if build.with? 'ossp-uuid'
    args << "--with-python" if build.with? 'python'
    args << "--with-perl" unless build.include? 'no-perl'
    args << "--with-tcl" unless build.include? 'no-tcl'
    args << "--with-krb5" unless build.include? 'no-krb5'
    args << "--with-ldap" unless build.include? 'no-ldap'
    args << "--with-libxml" unless build.include? 'no-xml'
    args << "--with-libxslt" unless build.include? 'no-xslt'
    args << "--with-bonjour" unless build.include? 'no-bonjour'
    args << "--with-pam" unless build.include? 'no-pam'
    args << "--enable-dtrace" if build.include? 'enable-dtrace'

    if build.with? 'ossp-uuid'
      ENV.append 'CFLAGS', `uuid-config --cflags`.strip
      ENV.append 'LDFLAGS', `uuid-config --ldflags`.strip
      ENV.append 'LIBS', `uuid-config --libs`.strip
    end

    if build.build_32_bit?
      ENV.append 'CFLAGS', "-arch #{MacOS.preferred_arch}"
      ENV.append 'LDFLAGS', "-arch #{MacOS.preferred_arch}"
    end

    system "./configure", *args
    system "make install"
    system "make -C contrib install"
  end

  def post_install
    unless File.exist? "#{var}/postgres"
      system "#{bin}/initdb", "#{var}/postgres"
    end
  end

  def caveats
    s = <<-EOS.undent
    If builds of PostgreSQL 9 are failing and you have version 8.x installed,
    you may need to remove the previous version first. See:
      https://github.com/Homebrew/homebrew/issues/issue/2510

    To migrate existing data from a previous major version (pre-9.4) of PostgreSQL, see:
      http://www.postgresql.org/docs/9.4/static/upgrading.html
    EOS

    s << "\n" << gem_caveats if MacOS.prefer_64_bit?
    return s
  end

  def gem_caveats; <<-EOS.undent
    When installing the postgres gem, including ARCHFLAGS is recommended:
      ARCHFLAGS="-arch x86_64" gem install pg

    To install gems without sudo, see the Homebrew wiki.
    EOS
  end

  plist_options :manual => "postgres -D #{HOMEBREW_PREFIX}/var/postgres"

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
        <string>#{opt_bin}/postgres</string>
        <string>-D</string>
        <string>#{var}/postgres</string>
        <string>-r</string>
        <string>#{var}/postgres/server.log</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{HOMEBREW_PREFIX}</string>
      <key>StandardErrorPath</key>
      <string>#{var}/postgres/server.log</string>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/initdb", testpath
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
