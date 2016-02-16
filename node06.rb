class Node06 < Formula
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/v0.6.21/node-v0.6.21.tar.gz"
  sha256 "22265fd07e09c22f1d058156d548e7398c9740210f534e2f848eeab5b9772117"
  revision 1

  bottle do
    revision 1
    sha256 "1cd2e47454085ccf21ca1b5a6e9366ec0f6ba0f6d7f5bd20d08f830b3df70d48" => :yosemite
    sha256 "b758f04ea1979adfe27cf6c4f161d98698d6056d8b0d1fe47071ffb702b1f81e" => :mavericks
    sha256 "f863b0e8a60b16e18deac5d49ab4a85f75995cf09defcadd1cfd41eb366b7ef7" => :mountain_lion
  end

  option "with-debug", "Build with debugger hooks"

  deprecated_option "enable-debug" => "with-debug"

  depends_on "openssl"

  fails_with :llvm do
    build 2326
  end

  env :std

  conflicts_with "node",
    :because => "Differing versions of the same formulae."

  def install
    inreplace "wscript" do |s|
      s.gsub! "/usr/local", HOMEBREW_PREFIX
      s.gsub! "/opt/local/lib", "/usr/lib"
    end

    args = ["--prefix=#{prefix}", "--without-npm"]
    args << "--debug" if build.with? "debug"
    args << "--openssl-includes=#{Formula["openssl"].include}"
    args << "--openssl-libpath=#{Formula["openssl"].lib}"

    system "./configure", *args
    system "make", "install"
  end

  def caveats
    <<-EOS.undent
      Homebrew has NOT installed npm.

      After installing, add the following path to your NODE_PATH environment
      variable to have npm libraries picked up:
        #{HOMEBREW_PREFIX}/lib/node_modules
    EOS
  end
end
