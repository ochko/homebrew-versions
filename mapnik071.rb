require 'formula'

class Mapnik071 < Formula
  homepage 'http://www.mapnik.org/'
  url 'http://download.berlios.de/mapnik/mapnik-0.7.1.tar.gz'
  sha1 '5fc9152574ac72c4063af9a4716739c793ec7b5b'

  depends_on 'pkg-config' => :build
  depends_on 'scons' => :build
  depends_on 'libtiff'
  depends_on 'jpeg'
  depends_on 'proj'
  depends_on 'icu4c'
  depends_on 'boost'
  depends_on 'freetype'
  depends_on 'cairomm' => :optional

  def install
    # Allow compilation against boost 1.46
    inreplace ["src/datasource_cache.cpp", "src/libxml2_loader.cpp", "src/load_map.cpp", "src/tiff_reader.cpp"],
      "#include <boost/filesystem/operations.hpp>",
      "#define BOOST_FILESYSTEM_VERSION 2\n#include <boost/filesystem/operations.hpp>"

    icu = Formula["icu4c"]
    scons "PREFIX=#{prefix}", "ICU_INCLUDES=#{icu.include}", "ICU_LIBS=#{icu.lib}", "install"
  end
end
