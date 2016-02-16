class Jpeg9 < Formula
  desc "JPEG image manipulation library"
  homepage "http://www.ijg.org"
  url "http://www.ijg.org/files/jpegsrc.v9.tar.gz"
  sha256 "c4e29e9375aaf60b4b79db87a58b063fb5b84f923bee97a88280b3d159e7e535"
  version "9.0"

  bottle do
    cellar :any
    sha256 "9061df1faf981bb9e064d58a6a72b0339cf00b0824da8f09b911026a3740fef0" => :yosemite
    sha256 "969b3b006f8eddbd66c4d293d4732783510ed04346151497d204c1da3ad46c04" => :mavericks
    sha256 "be2a94a1715e16a4097ac00c7d9b5f3d4ebc64e96027bc4a40b321bb5da27eea" => :mountain_lion
  end

  option :universal

  # https://trac.macports.org/ticket/37984
  patch :DATA

  def install
    ENV.universal_binary if build.universal?

    # Builds static and shared libraries.
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/djpeg", test_fixtures("test.jpg")
  end
end

__END__
--- a/jmorecfg.h
+++ b/jmorecfg.h
@@ -252,17 +252,16 @@ typedef void noreturn_t;
  * Defining HAVE_BOOLEAN before including jpeglib.h should make it work.
  */
 
-#ifdef HAVE_BOOLEAN
+#ifndef HAVE_BOOLEAN
+typedef int boolean;
+#endif
+
 #ifndef FALSE			/* in case these macros already exist */
 #define FALSE	0		/* values of boolean */
 #endif
 #ifndef TRUE
 #define TRUE	1
 #endif
-#else
-typedef enum { FALSE = 0, TRUE = 1 } boolean;
-#endif
-
 
 /*
  * The remaining options affect code selection within the JPEG library,

