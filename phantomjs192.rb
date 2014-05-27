require 'formula'

class Phantomjs192 < Formula
  homepage 'http://www.phantomjs.org/'
  url 'https://phantomjs.googlecode.com/files/phantomjs-1.9.2-macosx.zip'
  sha1 '36357dc95c0676fb4972420ad25455f49a8f3331'

  depends_on :macos => :snow_leopard

  def install
    bin.install 'bin/phantomjs'
  end
end
