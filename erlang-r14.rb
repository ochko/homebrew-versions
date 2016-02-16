class ErlangR14 < Formula
  homepage "http://www.erlang.org"
  # Download tarball from GitHub; it is served faster than the official tarball.
  url "https://github.com/erlang/otp/archive/OTP_R14B04.tar.gz"
  sha256 "6f11a10b9cd9a2a6480e7c387ea475394262e02b2b1b55269f3df3eb4b70fca0"
  revision 1

  bottle do
    sha256 "ed4bb782f85cd3a74d88cfa584715fe9461f620b3d64648e8955175485b9082a" => :yosemite
    sha256 "46cf7c0c7a081119d05172cdee2f0c68f41168a273febd623ec3bcade0f3e5ec" => :mavericks
    sha256 "6a83f8d9920adffab06d16601cad43153a138c46a4bd9b4d98aa8c19293d1342" => :mountain_lion
  end

  option "disable-hipe", "Disable building hipe; fails on various OS X systems"
  option "halfword", "Enable halfword emulator (64-bit builds only)"
  option "no-docs", "Do not install documentation"

  # Detection of odbc header files seems to be broken, so let the formula user
  # decide whether or not this is needed.
  option "with-odbc", "Build the Erlang odbc application"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "unixodbc" if build.with? "odbc"
  depends_on "openssl"

  conflicts_with "erlang", :because => "Different version of same formula"

  resource "man" do
    url "http://erlang.org/download/otp_doc_man_R14B04.tar.gz"
    sha256 "8514511e8a8ac3f3f67db06f333548edf283d9a8afcbc9e9eeca7b1af9a107da"
  end

  resource "html" do
    url "http://erlang.org/download/otp_doc_html_R14B04.tar.gz"
    sha256 "3b066d23d82667e2d0477856b22ea94262d65baf7366babe1c10d8bddc28ab5a"
  end

  # This applies a patch from the Erlbrew project
  # (https://github.com/mrallen1/erlbrew) that fixes build
  # errors with llvm-gcc and clang.
  patch :p0, :DATA

  def install
    ohai "Compilation may take a very long time; use `brew install -v erlang` to see progress"
    ENV.deparallelize

    # This works in tandem with the erlbrew patch
    ENV.append_to_cflags "-DERTS_DO_INCL_GLB_INLINE_FUNC_DEF"

    # Do this if building from a checkout to generate configure
    system "./otp_build autoconf" if File.exist? "otp_build"

    args = ["--disable-debug",
            "--prefix=#{prefix}",
            "--enable-kernel-poll",
            "--enable-threads",
            "--enable-dynamic-ssl-lib",
            "--enable-shared-zlib",
            "--enable-smp-support"]

    unless build.include? "disable-hipe"
      # HIPE doesn't strike me as that reliable on OS X
      # http://syntatic.wordpress.com/2008/06/12/macports-erlang-bus-error-due-to-mac-os-x-1053-update/
      # http://www.erlang.org/pipermail/erlang-patches/2008-September/000293.html
      args << "--enable-hipe"
    end

    if MacOS.prefer_64_bit?
      args << "--enable-darwin-64bit"
      args << "--enable-halfword-emulator" if build.include? "halfword" # Does not work with HIPE yet. Added for testing only
    end

    # Detection of odbc library and headers is slightly flaky, so be explicit about
    # configuring it
    args << (build.with?("odbc") ? "--with-odbc" : "--without-odbc")

    system "./configure", *args
    touch "lib/wx/SKIP" if MacOS.version >= :snow_leopard
    system "make"
    system "make", "install"

    unless build.include? "no-docs"
      resource("man").stage { man.install Dir["man/*"] }
      resource("html").stage { doc.install Dir["*"] }
    end
  end

  test do
    system "#{bin}/erl", "-noshell", "-eval", "crypto:start().", "-s", "init", "stop"
  end
end

__END__
--- erts/emulator/beam/beam_bp.c.orig	2011-10-03 13:12:07.000000000 -0500
+++ erts/emulator/beam/beam_bp.c	2013-10-04 13:42:03.000000000 -0500
@@ -496,7 +496,8 @@
 }

 /* bp_hash */
-ERTS_INLINE Uint bp_sched2ix() {
+#ifndef ERTS_DO_INCL_GLB_INLINE_FUNC_DEF
+ERTS_GLB_INLINE Uint bp_sched2ix() {
 #ifdef ERTS_SMP
     ErtsSchedulerData *esdp;
     esdp = erts_get_scheduler_data();
@@ -505,6 +506,7 @@
     return 0;
 #endif
 }
+#endif
 static void bp_hash_init(bp_time_hash_t *hash, Uint n) {
     Uint size = sizeof(bp_data_time_item_t)*n;
     Uint i;
--- erts/emulator/beam/beam_bp.h.orig	2011-10-03 13:12:07.000000000 -0500
+++ erts/emulator/beam/beam_bp.h	2013-10-04 13:42:08.000000000 -0500
@@ -144,7 +144,19 @@
 #define ErtsSmpBPUnlock(BDC)
 #endif

-ERTS_INLINE Uint bp_sched2ix(void);
+ERTS_GLB_INLINE Uint bp_sched2ix(void);
+
+#ifdef ERTS_DO_INCL_GLB_INLINE_FUNC_DEF
+ERTS_GLB_INLINE Uint bp_sched2ix() {
+#ifdef ERTS_SMP
+    ErtsSchedulerData *esdp;
+    esdp = erts_get_scheduler_data();
+    return esdp->no - 1;
+#else
+    return 0;
+#endif
+}
+#endif

 #ifdef ERTS_SMP
 #define bp_sched2ix_proc(p) ((p)->scheduler_data->no - 1)
