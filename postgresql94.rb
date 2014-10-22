require 'formula'

class Postgresql94 < Formula
  homepage 'http://www.postgresql.org/'
  url 'http://ftp.postgresql.org/pub/source/v9.4beta3/postgresql-9.4beta3.tar.bz2'
  version '9.4beta3'
  sha256 '5ad1d86a5b9a70d5c153dd862b306a930c6cf67fb4a3f00813eef19fabe6aa5d'
  head 'http://git.postgresql.org/git/postgresql.git', :branch => 'REL9_4_STABLE'

  keg_only 'The different provided versions of PostgreSQL conflict with each other.'

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
  option 'with-e2fs', 'Build with e2fs for UUID support'
  option 'with-ossp', 'Build with ossp for UUID support'
  option 'enable-dtrace', 'Build with DTrace support'

  depends_on 'openssl'
  depends_on 'gettext'
  depends_on 'readline'
  depends_on 'libxml2' => :optional
  depends_on 'ossp-uuid' => :optional
  depends_on 'python' => :optional
  depends_on 'e2fsprogs' => :recommended

  conflicts_with 'postgres-xc', 'postgresql',
    :because => 'postgresql and postgres-xc install the same binaries.'

  fails_with :clang do
    build 211
    cause 'Miscompilation resulting in segfault on queries'
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

    if build.with? 'with-e2fs'
      args << "--with-uuid=e2fs"
    elsif build.with? 'with-ossp'
      args << "--with-ossp-uuid"

      ENV.append 'CFLAGS', `uuid-config --cflags`.strip
      ENV.append 'LDFLAGS', `uuid-config --ldflags`.strip
      ENV.append 'LIBS', `uuid-config --libs`.strip
    end

    if build.build_32_bit?
      ENV.append 'CFLAGS', "-arch #{MacOS.preferred_arch}"
      ENV.append 'LDFLAGS', "-arch #{MacOS.preferred_arch}"
    end

    system "./configure", *args

    if build.head?
      # XXX Can't build docs using Homebrew-provided software, so skip
      # it when building from Git.
      system "make install"
      system "make -C contrib install"
    else
      system "make install-world"
    end
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

    To use this PostgreSQL installation, do one or more of the following:

    - Call all programs explicitly with #{opt_prefix}/bin/...
    - Add #{opt_prefix}/bin to your PATH
    - brew link -f #{name}
    - Install the postgresql-common package
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
