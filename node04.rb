class Node04 < Formula
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/node-v0.4.12.tar.gz"
  sha256 "c01af05b933ad4d2ca39f63cac057f54f032a4d83cff8711e42650ccee24fce4"
  revision 1

  bottle do
    revision 1
    sha256 "30c8b596cf0184fd7608b5370b5e10c3adf453e899fa90dfa72215837eaf499a" => :mountain_lion
  end

  option "with-debug", "Build with debugger hooks"

  deprecated_option "enable-debug" => "with-debug"

  depends_on "openssl"
  depends_on MaximumMacOSRequirement => :mountain_lion

  fails_with :llvm do
    build 2326
  end

  # Fixes the build on 10.8, but 10.9 onwards is dead.
  # https://github.com/Homebrew/homebrew-versions/pull/665
  env :std

  conflicts_with "node",
    :because => "Differing versions of the same formulae."

  def install
    inreplace "wscript" do |s|
      s.gsub! "/usr/local", HOMEBREW_PREFIX
      s.gsub! "/opt/local/lib", "/usr/lib"
    end

    args = ["--prefix=#{prefix}"]
    args << "--debug" if build.with? "debug"
    args << "--openssl-includes=#{Formula["openssl"].include}"
    args << "--openssl-libpath=#{Formula["openssl"].lib}"

    system "./configure", *args
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    For node to pick up installed libraries, add this to your profile:
      export NODE_PATH=#{HOMEBREW_PREFIX}/lib/node_modules
    EOS
  end
end
