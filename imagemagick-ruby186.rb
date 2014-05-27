# Ruby 1.8.6 requires a special version of imagemagick
# We simply revived an earlier version and added the suffix.
#   https://github.com/mxcl/homebrew/blob/685dbff9301c215ac6f7ca775bbe8eed2bf62662/Library/Formula/imagemagick.rb

require 'formula'

# some credit to http://github.com/maddox/magick-installer

class ImagemagickRuby186 < Formula
  homepage 'http://www.imagemagick.org'
  url 'http://download.sourceforge.net/project/imagemagick/old-sources/6.x/6.5/ImageMagick-6.5.9-10.tar.gz'
  sha1 'cd60f630037f659dc8833afa1b283321ec91b3dc'

  depends_on 'jpeg'
  depends_on 'libwmf' => :optional
  depends_on 'libtiff' => :optional
  depends_on 'little-cms' => :optional
  depends_on 'jasper' => :optional
  depends_on 'ghostscript' => :optional
  depends_on 'libpng12' # needs this old libpng. Not tested with 1.3 but 1.4 fails.
  depends_on :x11 => :optional

  def install
    ENV.deparallelize

    # versioned stuff in main tree is pointless for us
    inreplace 'configure', '${PACKAGE_NAME}-${PACKAGE_VERSION}', '${PACKAGE_NAME}'

    args = [ "--prefix=#{prefix}",
             "--disable-dependency-tracking",
             "--enable-shared",
             "--without-maximum-compile-warnings",
             "--disable-osx-universal-binary",
             "--disable-static",
             "--with-modules",
             "--without-perl", # I couldn't make this compile
             "--disable-openmp",
             "--without-magick-plus-plus" ]

     args << "--without-x" if build.without? 'x11'
     if build.with? 'ghostscript'
       args << '--without-ghostscript'
       args << "--with-gs-font-dir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts"
     end
    system "./configure", *args
    system "make install"

    # We already copy these into the keg root
    (share+"ImageMagick/NEWS.txt").unlink
    (share+"ImageMagick/LICENSE").unlink
    (share+"ImageMagick/ChangeLog").unlink
  end
end
