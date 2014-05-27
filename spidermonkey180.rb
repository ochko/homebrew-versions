require 'formula'

class Spidermonkey180 < Formula
  homepage 'https://developer.mozilla.org/en/SpiderMonkey'
  # Pick a version that's known to work with CouchDB), revision r35345.
  url 'http://hg.mozilla.org/tracemonkey/archive/57a6ad20eae9.tar.gz'
  sha1 '4ee889408a6d5c2424b9367ff9a26e4dd91a3084'
  version '1.8.0'

  depends_on 'readline'
  depends_on 'nspr'

  # Private older version of autoconf required to compile Spidermonkey
  resource "autoconf213" do
    url "http://ftpmirror.gnu.org/autoconf/autoconf-2.13.tar.gz"
    mirror "http://ftp.gnu.org/gnu/autoconf/autoconf-2.13.tar.gz"
    sha1 "e4826c8bd85325067818f19b2b2ad2b625da66fc"
  end

  def install
    # aparently this flag causes the build to fail for ivanvc on 10.5 with a
    # penryn (core 2 duo) CPU. So lets be cautious here and remove it.
    ENV['CFLAGS'] = ENV['CFLAGS'].gsub(/-msse[^\s]+/, '') if MacOS.version == :leopard

    # For some reason SpiderMonkey requires Autoconf-2.13
    ac213_prefix = buildpath/"ac213"
    resource("autoconf213").stage do
      # Force use of plain "awk"
      inreplace 'configure', 'for ac_prog in mawk gawk nawk awk', 'for ac_prog in awk'

      system "./configure", "--disable-debug",
                            "--program-suffix=213",
                            "--prefix=#{ac213_prefix}"
      system "make install"
    end

    cd "js/src" do
      # Fixes a bug with linking against CoreFoundation. Tests all pass after
      # building like this. See: http://openradar.appspot.com/7209349
      inreplace "configure.in", "LDFLAGS=\"$LDFLAGS -framework Cocoa\"", ""
      system "#{ac213_prefix}/bin/autoconf213"

      # Remove the broken *(for anyone but FF) install_name
      inreplace "config/rules.mk",
        "-install_name @executable_path/$(SHARED_LIBRARY) ",
        "-install_name #{lib}/$(SHARED_LIBRARY) "
    end

    mkdir "brew-build" do
      system "../js/src/configure", "--prefix=#{prefix}",
                                    "--enable-readline",
                                    "--enable-threadsafe",
                                    "--with-system-nspr"

      inreplace "js-config", /JS_CONFIG_LIBS=.*?$/, "JS_CONFIG_LIBS=''"
      # These need to be in separate steps.
      system "make"
      system "make install"

      # Also install js REPL.
      bin.install "shell/js"
    end
  end

  def caveats; <<-EOS.undent
    This formula installs Spidermonkey 1.8.x.

    If you are trying to compile MongoDB from scratch, you will need 1.7.x instead.
    EOS
  end
end
