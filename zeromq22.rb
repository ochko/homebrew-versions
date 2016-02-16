class Zeromq22 < Formula
  desc "High-performance, asynchronous messaging library"
  homepage "http://www.zeromq.org/"
  url "http://download.zeromq.org/zeromq-2.2.0.tar.gz"
  sha256 "43904aeb9ea6844f72ca02e4e53bf1d481a1a0264e64979da761464e88604637"

  keg_only "Conflicts with zeromq in main repository."

  option :universal
  option "with-pgm", "Build with PGM extension"

  depends_on "pkg-config" => :build
  depends_on "libpgm" if build.with? "pgm"

  fails_with :llvm do
    build 2326
    cause "Segfault while linking"
  end

  def pgm_flags
    build.with?("pgm") ? "--with-system-pgm" : ""
  end

  def build_fat
    # make 32-bit
    system "CFLAGS=\"$CFLAGS -arch i386\" CXXFLAGS=\"$CXXFLAGS -arch i386\" ./configure --disable-dependency-tracking --prefix='#{prefix}' #{pgm_flags}"
    system "make"
    mv "src/.libs", "src/libs-32"
    system "make", "clean"

    # make 64-bit
    system "CFLAGS=\"$CFLAGS -arch x86_64\" CXXFLAGS=\"$CXXFLAGS -arch x86_64\" ./configure --disable-dependency-tracking --prefix='#{prefix}' #{pgm_flags}"
    system "make"
    mv "src/.libs/libzmq.1.dylib", "src/.libs/libzmq.64.dylib"

    # merge UB
    system "lipo", "-create", "src/libs-32/libzmq.1.dylib",
                              "src/.libs/libzmq.64.dylib",
                   "-output", "src/.libs/libzmq.1.dylib"
  end

  def do_config
    args = ["--disable-dependency-tracking", "--prefix=#{prefix}"]
    if build.with? "pgm"
      # Use HB libpgm-5.2 because their internal 5.1 is b0rked.
      ENV["OpenPGM_CFLAGS"] = `pkg-config --cflags openpgm-5.2`.chomp
      ENV["OpenPGM_LIBS"] = `pkg-config --libs openpgm-5.2`.chomp
      args << "--with-system-pgm"
    end
    system "./configure", *args
  end

  def install
    if build.universal?
      ENV.permit_arch_flags
      build_fat
    else
      do_config
    end

    system "make"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    To install the zmq gem on 10.6 with the system Ruby on a 64-bit machine,
    you may need to do:

        ARCHFLAGS="-arch x86_64" gem install zmq -- --with-zmq-dir=#{HOMEBREW_PREFIX}

    If you want to build the Java bindings from https://github.com/zeromq/jzmq
    you will need the Java Developer Package from http://connect.apple.com/
    EOS
  end
end
