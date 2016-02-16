class ErlangR13 < Formula
  homepage "http://www.erlang.org"
  # Download from GitHub. Much faster than official tarball.
  url "https://github.com/erlang/otp/archive/OTP_R13B04.tar.gz"
  sha256 "a4b04786dbcf92446540104f5992c58e55baab606835fc0a087c5e22e7bab125"
  revision 1

  bottle do
    sha256 "6e60e6bd0aff46d0b30365d6abe335d3ab6f235c63f6606151461eac98db2aaf" => :yosemite
    sha256 "83ff1c045b09a3e97801d98a158d2eb31567452cdb56848a0bf969fc66adafc3" => :mavericks
    sha256 "c84ff9de2082588a9a8f1a71a1435756394b128665c1926ff52a7db169e2f338" => :mountain_lion
  end

  option "without-hipe", "Disable building hipe; fails on various OS X systems"
  option "without-docs", "Do not install documentation"

  deprecated_option "disable-hipe" => "without-hipe"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "openssl"
  depends_on "unixodbc" if MacOS.version >= :mavericks

  conflicts_with "erlang", :because => "Different version of same formula"

  fails_with :llvm do
    build 2326
    cause "See: http://github.com/mxcl/homebrew/issues/issue/120"
  end

  resource "man" do
    url "http://www.erlang.org/download/otp_doc_man_R13B04.tar.gz"
    sha256 "3646198b64bbea0f3760987d20d3392b0b5b2955394a917b92a2c6664a310dd6"
  end

  def install
    ohai "Compilation takes a long time; use `brew install -v erlang-r16` to see progress" unless ARGV.verbose?
    ENV.deparallelize

    system "./otp_build autoconf" if File.exist? "otp_build"

    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --enable-kernel-poll
      --enable-threads
      --enable-dynamic-ssl-lib
      --with-ssl=#{Formula["openssl"].opt_prefix}
      --enable-smp-support
    ]

    if build.with? "hipe"
      # HIPE doesn't strike me as that reliable on OS X
      # https://syntatic.wordpress.com/2008/06/12/macports-erlang-bus-error-due-to-mac-os-x-1053-update/
      # http://www.erlang.org/pipermail/erlang-patches/2008-September/000293.html
      args << "--enable-hipe"
    end

    args << "--enable-darwin-64bit" if MacOS.prefer_64_bit?

    system "./configure", *args
    touch "lib/wx/SKIP" if MacOS.version >= :snow_leopard
    system "make"
    system "make", "install"

    resource("man").stage { man.install Dir["man/*"] } if build.with? "docs"
  end

  test do
    system bin/"erl", "-noshell", "-eval", "crypto:start().", "-s", "init", "stop"
  end
end
