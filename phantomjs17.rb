require 'formula'

class Phantomjs17 < Formula
  homepage 'http://www.phantomjs.org/'
  url 'https://phantomjs.googlecode.com/files/phantomjs-1.7.0-macosx.zip'
  sha1 'de9ed8092d7fd5095447ada2cf96efb6c949b359'

  depends_on :macos => :snow_leopard

  def install
    bin.install 'bin/phantomjs'
  end
end
