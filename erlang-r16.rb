class ErlangR16 < Formula
  homepage "http://www.erlang.org"
  url "http://www.erlang.org/download/otp_src_R16B03-1.tar.gz"
  sha256 "17ce53459bc5ceb34fc2da412e15ac8c23835a15fbd84e62c8d1852704747ee7"
  revision 2

  bottle do
    sha256 "46ff2e3066bc4fdb2bca0b4cf954d6ef50c4a161301d74fe4770f7dc4c6a9acb" => :yosemite
    sha256 "9da63d7852b36d2659a8eaedadf21650430b8408692174369818df01d13fb097" => :mavericks
    sha256 "943c59a888292edafb974460671327602deda37223680d52fd96dc152c1b99c7" => :mountain_lion
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "openssl"
  depends_on "unixodbc" if MacOS.version >= :mavericks
  depends_on "fop" => :optional # enables building PDF docs
  depends_on "wxmac" => :recommended # for GUI apps like observer

  conflicts_with "erlang", :because => "Different version of same formula"

  fails_with :llvm

  option "without-hipe", "Disable building hipe; fails on various OS X systems"
  option "with-halfword", "Enable halfword emulator (64-bit builds only)"
  option "without-docs", "Do not install documentation"

  deprecated_option "disable-hipe" => "without-hipe"
  deprecated_option "halfword" => "with-halfword"
  deprecated_option "no-docs" => "without-docs"

  resource "man" do
    url "http://erlang.org/download/otp_doc_man_R16B03-1.tar.gz"
    sha256 "0f31bc7d7215aa4b6834b1a565cd7d6e3173e3b392fb870254bae5136499c39d"
  end

  resource "html" do
    url "http://erlang.org/download/otp_doc_html_R16B03-1.tar.gz"
    sha256 "5381d4ffe654e3e943f004e2b91870bd83f0e46e261bb405c1cdf7de81bc0507"
  end

  def install
    ohai "Compilation takes a long time; use `brew install -v erlang-r16` to see progress" unless ARGV.verbose?

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
      # HIPE doesn't strike me as that reliable on OS X
      # http://syntatic.wordpress.com/2008/06/12/macports-erlang-bus-error-due-to-mac-os-x-1053-update/
      # http://www.erlang.org/pipermail/erlang-patches/2008-September/000293.html
      args << "--enable-hipe"
    end

    if MacOS.prefer_64_bit?
      args << "--enable-darwin-64bit"
      args << "--enable-halfword-emulator" if build.with? "halfword" # Does not work with HIPE yet. Added for testing only
    end

    system "./configure", *args
    system "make"
    ENV.deparallelize # Install is not thread-safe; can try to create folder twice and fail
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
