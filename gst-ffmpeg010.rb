require 'formula'

class GstFfmpeg010 < Formula
  homepage 'http://gstreamer.freedesktop.org/'
  url 'http://gstreamer.freedesktop.org/src/gst-ffmpeg/gst-ffmpeg-0.10.13.tar.bz2'
  sha1 '8de5c848638c16c6c6c14ce3b22eecd61ddeed44'

  depends_on 'pkg-config' => :build
  depends_on 'gettext'
  depends_on 'homebrew/versions/gst-plugins-base010'

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-ffmpeg-extra-configure=--cc=#{ENV.cc}"
    system "make install"
  end
end
