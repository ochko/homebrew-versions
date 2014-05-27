require 'formula'

class Protobuf240a < Formula
  homepage 'http://code.google.com/p/protobuf/'
  url 'https://protobuf.googlecode.com/files/protobuf-2.4.0a.tar.bz2'
  sha1 '5816b0dd686115c3d90c3beccf17fd89432d3f07'

  keg_only 'Conflicts with protobuf in main repository.'

  option :universal

  fails_with :llvm do
    build 2334
  end

  # make it build with clang and libc++
  def patches; DATA; end

  def install
    # Don't build in debug mode. See:
    # https://github.com/mxcl/homebrew/issues/9279
    # http://code.google.com/p/protobuf/source/browse/trunk/configure.ac#61
    ENV.prepend 'CXXFLAGS', '-DNDEBUG'
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-zlib"
    system "make"
    system "make install"

    # Install editor support and examples
    doc.install %w( editors examples )
  end

  def caveats; <<-EOS.undent
    Editor support and examples have been installed to:
      #{doc}
    EOS
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
