class Phantomjs182 < Formula
  homepage "http://www.phantomjs.org/"
  url "https://phantomjs.googlecode.com/files/phantomjs-1.8.2-macosx.zip"
  sha256 "7d19c1cce6c66bb3153d335522b4effe68ddd249f427776b82f2662fb5ed81cf"

  depends_on :macos => :snow_leopard

  def install
    bin.install "bin/phantomjs"
  end
end
