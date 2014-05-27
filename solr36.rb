require 'formula'

class Solr36 < Formula
  homepage 'http://lucene.apache.org/solr/'
  url 'http://archive.apache.org/dist/lucene/solr/3.6.2/apache-solr-3.6.2.tgz'
  sha1 '3a1a40542670ea6efec246a081053732c5503ec1'

  def script; <<-EOS.undent
    #!/bin/sh
    if [ -z "$1" ]; then
      echo "Usage: $ solr36 path/to/config/dir"
    else
      cd #{libexec}/example && java -Dsolr.solr.home=$1 -jar start.jar
    fi
    EOS
  end

  def install
    libexec.install Dir['*']
    (bin+'solr36').write script
    (var+'logs'+name).mkpath
    (etc+name).mkpath
    (etc+name).install Dir[libexec+'example/multicore'] unless (etc+name+'multicore').exist?
  end

  def caveats; <<-EOS.undent
    To start solr:
      solr path/to/solr/config/dir

    See the solr homepage for more setup information:
      brew home solr
    EOS
  end

  def plist; <<-EOS.undent
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>ProgramArguments</key>
          <array>
            <string>/usr/bin/java</string>
            <string>-Djetty.home=#{libexec}/example</string>
            <string>-Djetty.logs=#{var}/logs/#{name}</string>
            <string>-Dsolr.solr.home=#{etc+name+'multicore'}</string>
            <string>-jar</string>
            <string>#{libexec}/example/start.jar</string>
          </array>
          <key>ServiceDescription</key>
          <string>Solr</string>
          <key>WorkingDirectory</key>
          <string>#{HOMEBREW_PREFIX}</string>
          <key>RunAtLoad</key>
          <true/>
      </dict>
      </plist>
    EOS
  end
end
