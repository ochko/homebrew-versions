require 'formula'

class Jetty76 < Formula
  homepage 'http://www.eclipse.org/jetty/'
  url 'http://download.eclipse.org/jetty/stable-7/dist/jetty-distribution-7.6.15.v20140411.tar.gz'
  version '7.6.15'
  sha1 '732bfdb9570be6758d3bd5ca5bed9012e96348ac'

  def install
    rm_rf Dir['bin/*.{cmd,bat]}']

    libexec.install Dir['*']
    (libexec+'logs').mkpath

    bin.mkpath
    Dir["#{libexec}/bin/*.sh"].each do |f|
      scriptname = File.basename(f, '.sh')
      (bin+scriptname).write <<-EOS.undent
        #!/bin/bash
        JETTY_HOME=#{libexec}
        #{f} $@
      EOS
      chmod 0755, bin+scriptname
    end
  end
end
