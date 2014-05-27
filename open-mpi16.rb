require 'formula'

class OpenMpi16 < Formula
  homepage 'http://www.open-mpi.org/'
  url 'http://www.open-mpi.org/software/ompi/v1.6/downloads/openmpi-1.6.5.tar.bz2'
  sha1 '93859d515b33dd9a0ee6081db285a2d1dffe21ce'

  option 'disable-fortran', 'Do not build the Fortran bindings'
  option 'enable-mpi-thread-multiple', 'Enable MPI_THREAD_MULTIPLE'

  keg_only 'Conflicts with open-mpi in core repository.'

  depends_on :fortran unless build.include? 'disable-fortran'

  # Reported upstream at version 1.6, both issues
  # http://www.open-mpi.org/community/lists/devel/2012/05/11003.php
  # http://www.open-mpi.org/community/lists/devel/2012/08/11362.php
  fails_with :clang do
    cause 'fails make check on Lion and ML'
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --disable-silent-rules
      --enable-ipv6
    ]
    if build.include? 'disable-fortran'
      args << '--disable-mpi-f77' << '--disable-mpi-f90'
    end

    if build.include? 'enable-mpi-thread-multiple'
      args << '--enable-mpi-thread-multiple'
    end

    system './configure', *args
    system 'make', 'all'
    system 'make', 'check'
    system 'make', 'install'

    # If Fortran bindings were built, there will be a stray `.mod` file
    # (Fortran header) in `lib` that needs to be moved to `include`.
    include.install lib/'mpi.mod' if File.exists? "#{lib}/mpi.mod"

    # Not sure why the wrapped script has a jar extension - adamv
    libexec.install bin/'vtsetup.jar'
    bin.write_jar_script libexec/'vtsetup.jar', 'vtsetup.jar'
  end
end
