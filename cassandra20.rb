class Cassandra20 < Formula
  desc "Eventually consistent, distributed key-value store"
  homepage "https://cassandra.apache.org"
  url "https://archive.apache.org/dist/cassandra/2.0.11/apache-cassandra-2.0.11-bin.tar.gz"
  sha256 "f74c94e63c9dcb0cef6b627ea80ee0ad86da46ad7e7318bc6adf6821861d286b"

  bottle :unneeded

  conflicts_with "cassandra",
    :because => "cassandra20 and cassandra install different versions of the same binaries."

  def install
    (var/"lib/cassandra").mkpath
    (var/"log/cassandra").mkpath
    (etc/"cassandra").mkpath

    inreplace "conf/cassandra.yaml", "/var/lib/cassandra", "#{var}/lib/cassandra"
    inreplace "conf/log4j-server.properties", "/var/log/cassandra", "#{var}/log/cassandra"
    inreplace "conf/cassandra-env.sh", "/lib/", "/"

    inreplace "bin/cassandra.in.sh" do |s|
      s.gsub! "CASSANDRA_HOME=\"`dirname \"$0\"`/..\"", "CASSANDRA_HOME=\"#{libexec}\""
      # Store configs in etc, outside of keg
      s.gsub! "CASSANDRA_CONF=\"$CASSANDRA_HOME/conf\"", "CASSANDRA_CONF=\"#{etc}/cassandra\""
      # Jars installed to prefix, no longer in a lib folder
      s.gsub! "\"$CASSANDRA_HOME\"/lib/*.jar", "\"$CASSANDRA_HOME\"/*.jar"
      # The jammm Java agent is not in a lib/ subdir either:
      s.gsub! "JAVA_AGENT=\"$JAVA_AGENT -javaagent:$CASSANDRA_HOME/lib/jamm-", "JAVA_AGENT=\"$JAVA_AGENT -javaagent:$CASSANDRA_HOME/jamm-"
    end

    rm Dir["bin/*.bat"]

    (etc/"cassandra").install Dir["conf/*"]
    libexec.install Dir["*.txt", "{bin,interface,javadoc,pylib,lib/licenses}"]
    libexec.install Dir["lib/*.jar"]
    bin.write_exec_script Dir["#{libexec}/bin/*"]

    share.install [libexec/"bin/cassandra.in.sh", libexec/"bin/stop-server"]
    inreplace Dir["#{libexec}/bin/cassandra*", "#{libexec}/bin/debug-cql",
                  "#{libexec}/bin/json2sstable", "#{libexec}/bin/nodetool",
                  "#{libexec}/bin/sstable*"],
              %r{`dirname "?\$0"?`\/cassandra.in.sh},
              "#{share}/cassandra.in.sh"
  end

  def caveats; <<-EOS.undent
    If you plan to use the CQL shell (cqlsh), you will need the Python CQL library
    installed. Since Homebrew prefers using pip for Python packages, you can
    install that using:

      pip install cql
    EOS
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <true/>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_bin}/cassandra</string>
            <string>-f</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}/lib/cassandra</string>
      </dict>
    </plist>
    EOS
  end
end
