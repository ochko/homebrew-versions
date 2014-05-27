require 'formula'

class Hdf4 < Formula
  homepage 'http://www.hdfgroup.org'
  url 'http://www.hdfgroup.org/ftp/HDF/releases/HDF4.2.10/src/hdf-4.2.10.tar.bz2'
  sha1 '5163543895728dabb536a0659b3d965d55bccf74'

  option 'enable-fortran', 'Build Fortran interface.'

  depends_on 'cmake' => :build
  depends_on 'pkg-config' => :build
  depends_on 'szip'
  depends_on 'jpeg'
  depends_on :fortran if build.include? 'enable-fortran'

  def patches
    # redefine library name to "df" from "hdf".  this seems to be an artifact
    # of using cmake that needs to be corrected for compatibility with
    # anything depending on hdf4.
    DATA
  end

  def install
    ENV['SZIP_INSTALL'] = HOMEBREW_PREFIX

    args = std_cmake_args
    args.concat [
      '-DBUILD_SHARED_LIBS=ON',
      '-DBUILD_TESTING=OFF',
      '-DHDF4_BUILD_TOOLS=ON',
      '-DHDF4_BUILD_UTILS=ON',
      '-DHDF4_BUILD_WITH_INSTALL_NAME=ON',
      '-DHDF4_ENABLE_JPEG_LIB_SUPPORT=ON',
      '-DHDF4_ENABLE_NETCDF=OFF', # Conflict. Just install NetCDF for this.
      '-DHDF4_ENABLE_SZIP_ENCODING=ON',
      '-DHDF4_ENABLE_SZIP_SUPPORT=ON',
      '-DHDF4_ENABLE_Z_LIB_SUPPORT=ON'
    ]
    if build.include? 'enable-fortran'
      args.concat %W[-DHDF4_BUILD_FORTRAN=ON -DCMAKE_Fortran_MODULE_DIRECTORY=#{include}]
    else
      args << '-DHDF4_BUILD_FORTRAN=OFF'
    end

    mkdir 'build' do
      system 'cmake', '..', *args
      system 'make install'

      # Remove stray ncdump executable as it conflicts with NetCDF.
      rm (bin + 'ncdump')
    end
  end

  def caveats; <<-EOS.undent
      HDF4 has been superseeded by HDF5.  However, the API changed
      substantially and some programs still require the HDF4 libraries in order
      to function.
    EOS
  end
end
__END__
diff --git a/CMakeLists.txt b/CMakeLists.txt
index ba2cf13..27a3df4 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -95,7 +95,7 @@ MARK_AS_ADVANCED (HDF4_NO_PACKAGES)
 # Set the core names of all the libraries
 #-----------------------------------------------------------------------------
 SET (HDF4_LIB_CORENAME              "hdf4")
-SET (HDF4_SRC_LIB_CORENAME          "hdf")
+SET (HDF4_SRC_LIB_CORENAME          "df")
 SET (HDF4_SRC_FCSTUB_LIB_CORENAME   "hdf_fcstub")
 SET (HDF4_SRC_FORTRAN_LIB_CORENAME  "hdf_fortran")
 SET (HDF4_MF_LIB_CORENAME           "mfhdf")
