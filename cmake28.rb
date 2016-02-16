class NoExpatFramework < Requirement
  def expat_framework
    "/Library/Frameworks/expat.framework"
  end

  satisfy :build_env => false do
    !File.exist? expat_framework
  end

  def message; <<-EOS.undent
    Detected #{expat_framework}

    This will be picked up by CMake's build system and likely cause the
    build to fail, trying to link to a 32-bit version of expat.

    You may need to move this file out of the way to compile CMake.
    EOS
  end
end

class Cmake28 < Formula
  desc "Cross-platform make"
  homepage "http://www.cmake.org/"
  url "http://www.cmake.org/files/v2.8/cmake-2.8.12.2.tar.gz"
  sha256 "8c6574e9afabcb9fc66f463bb1f2f051958d86c85c37fccf067eb1a44a120e5e"

  bottle do
    cellar :any
    sha256 "83602825b72eb79a9723cba0680acaa4b022fdf8d32cdc65d9241c243ff601f5" => :yosemite
    sha256 "945c415b7f278222d79947465488f7634b8c6690f0f2cd860cd923003c433a15" => :mavericks
    sha256 "1f7ece0c6138f9aff5af38e150d1029484dde289956e46c43c9ef3adab8aa12a" => :mountain_lion
  end

  depends_on NoExpatFramework

  conflicts_with "cmake", :because => "both install a cmake binary"
  conflicts_with "cmake30", :because => "both install a cmake binary"
  conflicts_with "cmake31", :because => "both install a cmake binary"

  def install
    args = %W[
      --prefix=#{prefix}
      --system-libs
      --no-system-libarchive
      --datadir=/share/cmake
      --docdir=/share/doc/cmake
      --mandir=/share/man
    ]

    system "./bootstrap", *args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"CMakeLists.txt").write("find_package(Ruby)")
    system "#{bin}/cmake", "."
  end
end
