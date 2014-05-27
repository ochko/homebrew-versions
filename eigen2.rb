require 'formula'

class Eigen2 < Formula
  homepage 'http://eigen.tuxfamily.org/'
  url 'http://bitbucket.org/eigen/eigen/get/2.0.17.tar.bz2'
  sha1 '461546be98b964d8d5d2adb0f1c31ba0e42efc38'

  depends_on 'cmake' => :build

  def install
    mkdir 'eigen-build' do
      args = std_cmake_args
      args << "-DCMAKE_BUILD_TYPE=Release"
      args << "-Dpkg_config_libdir='#{lib}'" << ".."
      system "cmake", *args
      system "make install"
    end
  end
end
