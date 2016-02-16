class Protobuf240a < Formula
  homepage "https://github.com/google/protobuf"
  url "https://launchpad.net/ubuntu/+archive/primary/+files/protobuf_2.4.0a.orig.tar.gz"
  sha256 "bb20941d4958bcf2fa76fde251bb4f71463d4fe28884a015c7335894344cffcb"

  bottle do
    cellar :any
    sha256 "19d29ffebfeb9beab833b7e8254ad19de11afea643bab6381dd51858e6a680db" => :yosemite
    sha256 "8e6160ffa4e7d1eeb4dd293b07fe4dd5fd78b134ee5a0af6e77053a57a0ccea2" => :mavericks
    sha256 "5de5e189c764f8f1922754a31f5d4151b9d65cf60b9fccd54ec727dbbf54ed0e" => :mountain_lion
  end

  keg_only "Conflicts with protobuf in main repository."

  option :universal

  fails_with :llvm do
    build 2334
  end

  # Fix build with clang and libc++
  patch :DATA

  def install
    # Don't build in debug mode. See:
    # https://github.com/homebrew/homebrew/issues/9279
    ENV.prepend "CXXFLAGS", "-DNDEBUG"
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-zlib"
    system "make"
    system "make", "install"

    # Install editor support and examples
    doc.install "editors", "examples"
  end

  def caveats; <<-EOS.undent
    Editor support and examples have been installed to:
      #{doc}
    EOS
  end

  test do
    (testpath/"test.proto").write <<-EOS.undent
      package test;
      message TestCase {
        required string name = 4;
      }
      message Test {
        repeated TestCase case = 1;
      }
    EOS

    system bin/"protoc", "test.proto", "--cpp_out=."
  end
end

__END__
diff --git a/src/google/protobuf/message.cc b/src/google/protobuf/message.cc
index 91e6878..0409a94 100644
--- a/src/google/protobuf/message.cc
+++ b/src/google/protobuf/message.cc
@@ -32,6 +32,7 @@
 //  Based on original Protocol Buffers design by
 //  Sanjay Ghemawat, Jeff Dean, and others.

+#include <istream>
 #include <stack>
 #include <google/protobuf/stubs/hash.h>
