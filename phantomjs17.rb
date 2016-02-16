class Phantomjs17 < Formula
  desc "Headless WebKit scriptable with a JavaScript API"
  homepage "http://www.phantomjs.org/"
  url "https://phantomjs.googlecode.com/files/phantomjs-1.7.0-macosx.zip"
  sha256 "5e3cd030dd0c420cc6e88aedff997a10c77322a9507f6be162e05a5894825705"

  depends_on :macos => :snow_leopard

  def install
    bin.install "bin/phantomjs"
  end
end
