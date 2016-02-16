class UniversalPython < Requirement
  satisfy(:build_env => false) { archs_for_command("python").universal? }

  def message; <<-EOS.undent
    A universal build was requested, but Python is not a universal build

    Boost compiles against the Python it finds in the path; if this Python
    is not a universal build then linking will likely fail.
    EOS
  end
end

class Boost149 < Formula
  desc "Collection of portable C++ source libraries"
  homepage "http://www.boost.org"
  url "https://downloads.sourceforge.net/project/boost/boost/1.49.0/boost_1_49_0.tar.bz2"
  sha256 "dd748a7f5507a7e7af74f452e1c52a64e651ed1f7263fce438a06641d2180d3c"

  bottle do
    sha256 "f885dbcfb802d0514d555b318f82d59293844811e4f197eae615088c8b3af442" => :yosemite
    sha256 "e2dc343ebf9c83f63d23c0a61a1e181ecf77cbdd1ce38e4568d9492c2c6bebab" => :mavericks
    sha256 "6f63a75817fca6d3da4d01588bbc6f358f55f497c9c2a8b033e04b3c4d169a9a" => :mountain_lion
  end

  keg_only "Boost 1.49 is provided for software that doesn't compile against newer versions."

  env :userpaths

  option :universal
  option "with-icu4c", "Build regexp engine with icu support"

  deprecated_option "with-icu" => "with-icu4c"

  depends_on :python => :recommended
  depends_on UniversalPython if build.universal? && build.with?("python")
  depends_on "icu4c" => :optional
  depends_on :mpi => [:cc, :cxx, :optional]

  fails_with :llvm do
    build 2335
    cause "Dropped arguments to functions when linking with boost"
  end

  # Security fix for Boost.Locale. For details: http://www.boost.org/users/news/boost_locale_security_notice.html
  patch :p0 do
    url "http://cppcms.com/files/locale/boost_locale_utf.patch"
    sha256 "8212150730073ba5b08aa9808afcb45d5ce90109cfc1ba90d22a673418ea003c"
  end

  def install
    # Adjust the name the libs are installed under to include the path to the
    # full keg library location.
    inreplace "tools/build/v2/tools/darwin.jam",
              '-install_name "',
              "-install_name \"#{lib}/"

    # Force boost to compile using the appropriate GCC version
    open("user-config.jam", "a") do |file|
      file.write "using darwin : : #{ENV.cxx} ;\n"
      file.write "using mpi ;\n" if build.with? "mpi"
    end

    # we specify libdir too because the script is apparently broken
    bargs = ["--prefix=#{prefix}", "--libdir=#{lib}", "--without-libraries=signals"]

    if build.with? "icu4c"
      bargs << "--with-icu=#{Formula["icu4c"].opt_prefix}"
    else
      bargs << "--without-icu"
    end

    args = ["--prefix=#{prefix}",
            "--libdir=#{lib}",
            "-d2",
            "-j#{ENV.make_jobs}",
            "--layout=tagged",
            "--user-config=user-config.jam",
            "threading=multi",
            "install"]

    args << "address-model=32_64" << "architecture=x86" << "pch=off" if build.universal?
    args << "--without-python" if build.without? "python"

    system "./bootstrap.sh", *bargs
    system "./bjam", *args
  end
end
