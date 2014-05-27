require 'formula'

class Node06 < Formula
  homepage 'http://nodejs.org/'
  url 'http://nodejs.org/dist/v0.6.21/node-v0.6.21.tar.gz'
  sha1 '31f564bf34c64b07cae3b9a88a87b4a08bab4dc5'

  option 'enable-debug', 'Build with debugger hooks'

  depends_on 'openssl' if MacOS.version == :leopard

  fails_with(:llvm) { build 2326 }

  def install
    inreplace 'wscript' do |s|
      s.gsub! '/usr/local', HOMEBREW_PREFIX
      s.gsub! '/opt/local/lib', '/usr/lib'
    end

    # Why skip npm install? Read https://github.com/mxcl/homebrew/pull/8784.
    args = ["--prefix=#{prefix}", "--without-npm"]
    args << "--debug" if build.include? 'enable-debug'

    system "./configure", *args
    system "make install"
  end

  def caveats
    <<-EOS.undent
      Homebrew has NOT installed npm. We recommend the following method of
      installation:
        curl http://npmjs.org/install.sh | sh

      After installing, add the following path to your NODE_PATH environment
      variable to have npm libraries picked up:
        #{HOMEBREW_PREFIX}/lib/node_modules
    EOS
  end
end
