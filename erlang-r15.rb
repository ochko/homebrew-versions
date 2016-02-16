class ErlangR15 < Formula
  homepage "http://www.erlang.org"
  # Download tarball from GitHub; it is served faster than the official tarball.
  url "https://github.com/erlang/otp/archive/OTP_R15B03-1.tar.gz"
  sha256 "cef717f102de0e6bc602dbcd6ef5328ce15dbcd0b8b4f04c96bc92e953f3a164"
  revision 1

  bottle do
    sha256 "ee8e05620de5ea113fc234268ef880a168285cdeaa018ec367dc5ff918500b75" => :yosemite
    sha256 "653639650d945f6219cb24bbbfe3792d4767ecd83170fb35afae56f651f1a043" => :mavericks
    sha256 "bd871db2f82beca53b107b3dd0385738ad2da756e73a8306a3f7f3b831a67e6c" => :mountain_lion
  end

  option "without-hipe", "Disable building hipe; fails on various OS X systems"
  option "with-halfword", "Enable halfword emulator (64-bit builds only)"
  option "without-docs", "Do not install documentation"

  deprecated_option "disable-hipe" => "without-hipe"
  deprecated_option "halfword" => "with-halfword"
  deprecated_option "no-docs" => "without-docs"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "openssl"
  depends_on "unixodbc" if MacOS.version >= :mavericks

  conflicts_with "erlang", :because => "Different version of same formula"

  fails_with :llvm

  resource "man" do
    url "http://erlang.org/download/otp_doc_man_R15B03-1.tar.gz"
    sha256 "07980d8014c7cf8194b7078c137353f5083992add4663ced3dcba2ff91f228d8"
  end

  resource "html" do
    url "http://erlang.org/download/otp_doc_html_R15B03-1.tar.gz"
    sha256 "d06f580f11d1303217a5c1cf8d68a98d7e01c535be934dcd430ecdc254f7572e"
  end

  def install
    ENV.deparallelize

    ohai "Compilation takes a long time; use `brew install -v erlang` to see progress" unless ARGV.verbose?

    # Do this if building from a checkout to generate configure
    system "./otp_build autoconf" if File.exist? "otp_build"

    args = %W[
      --disable-debug
      --prefix=#{prefix}
      --enable-kernel-poll
      --enable-threads
      --enable-dynamic-ssl-lib
      --with-ssl=#{Formula["openssl"].opt_prefix}
      --enable-shared-zlib
      --enable-smp-support
    ]

    args << "--with-dynamic-trace=dtrace" unless MacOS.version == :leopard || !MacOS::CLT.installed?

    if build.with? "hipe"
      # HIPE doesnt strike me as that reliable on OS X
      # http://syntatic.wordpress.com/2008/06/12/macports-erlang-bus-error-due-to-mac-os-x-1053-update/
      # http://www.erlang.org/pipermail/erlang-patches/2008-September/000293.html
      args << "--enable-hipe"
    end

    if MacOS.prefer_64_bit?
      args << "--enable-darwin-64bit"
      args << "--enable-halfword-emulator" if build.with? "halfword" # Does not work with HIPE yet. Added for testing only
    end

    system "./configure", *args
    touch "lib/wx/SKIP" if MacOS.version >= :snow_leopard
    system "make"
    system "make", "install"

    if build.with? "docs"
      resource("man").stage { man.install Dir["man/*"] }
      resource("html").stage { doc.install Dir["*"] }
    end
  end

  test do
    system bin/"erl", "-noshell", "-eval", "crypto:start().", "-s", "init", "stop"
  end
end
