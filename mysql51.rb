require 'formula'

class Mysql51 < Formula
  homepage 'http://dev.mysql.com/doc/refman/5.1/en/'
  url 'http://mysql.mirrors.pair.com/Downloads/MySQL-5.1/mysql-5.1.73.tar.gz'
  sha1 '6cb1c547dec873a0afda825c83fd8e5a32b9a619'

  option :universal
  option 'with-tests', 'Keep tests when installing'
  option 'with-bench', 'Keep benchmark app when installing'
  option 'with-embedded', 'Build the embedded server'
  option 'client-only', 'Only install client tools, not the server'
  option 'with-utf8-default', 'Set the default character set to utf8'

  keg_only 'Conflicts with mysql, mariadb, percona-server, mysql-cluster, etc.'

  depends_on 'readline'

  fails_with :clang

  def patches
    DATA
  end

  def install
    # Make universal for bindings to universal applications
    ENV.universal_binary if build.universal?

    configure_args = [
      "--without-docs",
      "--without-debug",
      "--disable-dependency-tracking",
      "--prefix=#{prefix}",
      "--localstatedir=#{var}/mysql",
      "--sysconfdir=#{etc}",
      "--with-plugins=innobase,myisam",
      "--with-extra-charsets=complex",
      "--with-ssl",
      "--without-readline", # Confusingly, means "use detected readline instead of included readline"
      "--enable-assembler",
      "--enable-thread-safe-client",
      "--enable-local-infile",
      "--enable-shared",
      "--with-partition"]

    configure_args << "--without-server" if build.include? 'client-only'
    configure_args << "--with-embedded-server" if build.with? 'embedded'
    configure_args << "--with-charset=utf8" if build.with? 'utf8-default'

    system "./configure", *configure_args
    system "make install"

    ln_s "#{libexec}/mysqld", bin
    ln_s "#{share}/mysql/mysql.server", bin

    (prefix+'mysql-test').rmtree if build.without? 'tests' # save 66MB!
    (prefix+'sql-bench').rmtree if build.without? 'bench'
  end

  def caveats; <<-EOS.undent
    Set up databases with:
        unset TMPDIR
        mysql_install_db
    EOS
  end

  plist_options :manual => "mysql.server start"

  def plist; <<-EOPLIST.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>KeepAlive</key>
      <true/>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>Program</key>
      <string>#{opt_prefix}/bin/mysqld_safe</string>
      <key>RunAtLoad</key>
      <true/>
      <key>WorkingDirectory</key>
      <string>#{var}</string>
    </dict>
    </plist>
    EOPLIST
  end
end


__END__
--- old/scripts/mysqld_safe.sh  2009-09-02 04:10:39.000000000 -0400
+++ new/scripts/mysqld_safe.sh  2009-09-02 04:52:55.000000000 -0400
@@ -384,7 +384,7 @@
 fi

 USER_OPTION=""
-if test -w / -o "$USER" = "root"
+if test -w /sbin -o "$USER" = "root"
 then
   if test "$user" != "root" -o $SET_USER = 1
   then
diff --git a/scripts/mysql_config.sh b/scripts/mysql_config.sh
index efc8254..8964b70 100644
--- a/scripts/mysql_config.sh
+++ b/scripts/mysql_config.sh
@@ -132,7 +132,8 @@ for remove in DDBUG_OFF DSAFEMALLOC USAFEMALLOC DSAFE_MUTEX \
               DEXTRA_DEBUG DHAVE_purify O 'O[0-9]' 'xO[0-9]' 'W[-A-Za-z]*' \
               'mtune=[-A-Za-z0-9]*' 'mcpu=[-A-Za-z0-9]*' 'march=[-A-Za-z0-9]*' \
               Xa xstrconst "xc99=none" AC99 \
-              unroll2 ip mp restrict
+              unroll2 ip mp restrict \
+              mmmx 'msse[0-9.]*' 'mfpmath=sse' w pipe 'fomit-frame-pointer' 'mmacosx-version-min=10.[0-9]'
 do
   # The first option we might strip will always have a space before it because
   # we set -I$pkgincludedir as the first option
