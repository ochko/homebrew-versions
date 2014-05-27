require 'formula'

class Ruby192 < Formula
  homepage 'http://www.ruby-lang.org/en/'
  url 'http://cache.ruby-lang.org/pub/ruby/1.9/ruby-1.9.2-p320.tar.bz2'
  sha256 '6777f865cfa21ffdc167fcc4a7da05cb13aab1bd9e59bfcda82c4b32f75e6b51'

  depends_on 'pkg-config' => :build
  depends_on 'readline'
  depends_on 'gdbm'
  depends_on 'libyaml'

  option :universal
  option 'with-suffix', 'Suffix commands with "192"'
  option 'with-doc', 'Install documentation'

  fails_with :llvm do
    build 2326
  end

  def install
    args = %W[--prefix=#{prefix}
              --enable-shared]

    args << "--program-suffix=192" if build.with? 'suffix'
    args << "--with-arch=x86_64,i386" if build.universal?

    # Put gem, site and vendor folders in the HOMEBREW_PREFIX
    ruby_lib = HOMEBREW_PREFIX/"lib/ruby"
    (ruby_lib/'site_ruby').mkpath
    (ruby_lib/'vendor_ruby').mkpath
    (ruby_lib/'gems').mkpath

    (lib/'ruby').install_symlink ruby_lib/'site_ruby',
                                 ruby_lib/'vendor_ruby',
                                 ruby_lib/'gems'

    system "./configure", *args
    system "make"
    system "make install"
    system "make install-doc" if build.with? 'doc'

  end

  def caveats; <<-EOS.undent
    NOTE: By default, gem installed binaries will be placed into:
      #{opt_prefix}/bin

    You may want to add this to your PATH.
    EOS
  end
end
