class Openjpeg21 < Formula
  desc "Library for JPEG-2000 image manipulation"
  homepage "http://www.openjpeg.org/"
  url "https://downloads.sourceforge.net/project/openjpeg.mirror/2.1.0/openjpeg-2.1.0.tar.gz"
  sha256 "1232bb814fd88d8ed314c94f0bfebb03de8559583a33abbe8c64ef3fc0a8ff03"

  bottle do
    cellar :any
    sha256 "f40e41ca1b1ee59149411ca5054bb7aded1323f64d5b84a30ff88377d946610d" => :yosemite
    sha256 "9004d4427b26fb5d5178c5c8e942cc225d6e5e9a2439d63fb74c4022ce87544a" => :mavericks
    sha256 "f1c0a8432b57e712d0281dc0093a1d072f6f51f3c9e81eb533faa182956d46e3" => :mountain_lion
  end

  depends_on "cmake" => :build
  depends_on "little-cms2"
  depends_on "libtiff"
  depends_on "libpng"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end
end
