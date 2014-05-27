require 'formula'

class ErlangR14 < Formula
  homepage 'http://www.erlang.org'
  # Download tarball from GitHub; it is served faster than the official tarball.
  url 'https://github.com/erlang/otp/archive/OTP_R14B04.tar.gz'
  sha1 '4c8f1dcb5cc9e39e7637a8022a93588823076f0e'

  option 'disable-hipe', 'Disable building hipe; fails on various OS X systems'
  option 'halfword', 'Enable halfword emulator (64-bit builds only)'
  option 'time', '`brew test --time` to include a time-consuming test'
  option 'no-docs', 'Do not install documentation'

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  fails_with :llvm

  resource 'man' do
    url 'http://erlang.org/download/otp_doc_man_R14B04.tar.gz'
    sha1 '41f4ea59c9622e39b30882e173983252b6faca81'
  end

  resource 'html' do
    url 'http://erlang.org/download/otp_doc_html_R14B04.tar.gz'
    sha1 '86f76adee9bf953e5578d7998fda9e7dfc0d43f5'
  end

  def install
    ohai "Compilation may take a very long time; use `brew install -v erlang` to see progress"
    ENV.deparallelize

    # Do this if building from a checkout to generate configure
    system "./otp_build autoconf" if File.exist? "otp_build"

    args = ["--disable-debug",
            "--prefix=#{prefix}",
            "--enable-kernel-poll",
            "--enable-threads",
            "--enable-dynamic-ssl-lib",
            "--enable-shared-zlib",
            "--enable-smp-support"]

    unless build.include? 'disable-hipe'
      # HIPE doesn't strike me as that reliable on OS X
      # http://syntatic.wordpress.com/2008/06/12/macports-erlang-bus-error-due-to-mac-os-x-1053-update/
      # http://www.erlang.org/pipermail/erlang-patches/2008-September/000293.html
      args << '--enable-hipe'
    end

    if MacOS.prefer_64_bit?
      args << "--enable-darwin-64bit"
      args << "--enable-halfword-emulator" if build.include? 'halfword' # Does not work with HIPE yet. Added for testing only
    end

    system "./configure", *args
    touch "lib/wx/SKIP" if MacOS.version >= :snow_leopard
    system "make"
    system "make install"

    unless build.include? 'no-docs'
      resource("man").stage { man.install Dir["man/*"] }
      resource("html").stage { doc.install Dir["*"] }
    end
  end

  test do
    `#{bin}/erl -noshell -eval 'crypto:start().' -s init stop`

    # This test takes some time to run, but per bug #120 should finish in
    # "less than 20 minutes". It takes a few minutes on a Mac Pro (2009).
    if build.include? "time"
      `#{bin}/dialyzer --build_plt -r #{lib}/erlang/lib/kernel-2.14.1/ebin/`
    end
  end
end
