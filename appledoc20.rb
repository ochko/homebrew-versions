require 'formula'

# The 2.1 series requires Lion or newer.
# 2.0.6 is provided for Snow Leopard compatibility.
class Appledoc20 < Formula
  homepage 'http://appledoc.gentlebytes.com/'
  url 'https://github.com/tomaz/appledoc/archive/v2.0.6.tar.gz'
  sha1 '3d76172339cbfea24ef53f55e2452cc78930413e'

  depends_on :xcode

  # Actually works with pre-503 clang, but we don't have a way to
  # express this yet.
  # clang 5.1 (build 503) removed support for Objective C GC, which
  # appledoc 2.0 requires to build.
  # It's actually possible to build with GC disabled, but not advisable.
  # See: https://github.com/tomaz/appledoc/issues/439
  fails_with :clang

  def install
    xcodebuild "-project", "appledoc.xcodeproj",
               "-target", "appledoc",
               "-configuration", "Release",
               "clean", "install",
               "SYMROOT=build",
               "DSTROOT=build",
               "INSTALL_PATH=/bin",
               "OTHER_CFLAGS='-DCOMPILE_TIME_DEFAULT_TEMPLATE_PATH=@\"#{prefix}/Templates\"'"
    bin.install "build/bin/appledoc"
    prefix.install "Templates/"
  end

  test do
    system "#{bin}/appledoc", "--version"
  end
end
