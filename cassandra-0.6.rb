class Cassandra06 < Formula
  desc "Eventually consistent, distributed key-value store"
  homepage "https://cassandra.apache.org"
  url "https://archive.apache.org/dist/cassandra/0.6.13/apache-cassandra-0.6.13-bin.tar.gz"
  sha256 "ed77d551b2cfed2bfc8e9896bd1afc501b41aa15fee83fbe9076b4e69b39e5d1"

  bottle :unneeded

  conflicts_with "cassandra", :because => "Differing versions of the same formula"

  def install
    (var/"lib/cassandra").mkpath
    (var/"log/cassandra").mkpath
    (etc/"cassandra").mkpath

    inreplace "conf/storage-conf.xml", "/var/lib/cassandra", "#{var}/lib/cassandra"
    inreplace "conf/log4j.properties", "/var/log/cassandra", "#{var}/log/cassandra"

    inreplace "bin/cassandra.in.sh" do |s|
      s.gsub! "cassandra_home=`dirname $0`/..", "cassandra_home=#{libexec}"
      # Store configs in etc, outside of keg
      s.gsub! "CASSANDRA_CONF=$cassandra_home/conf", "CASSANDRA_CONF=#{etc}/cassandra"
      # Jars installed to prefix, no longer in a lib folder
      s.gsub! "$cassandra_home/lib/*.jar", "$cassandra_home/*.jar"
    end

    rm Dir["bin/*.bat"]

    (etc/"cassandra").install Dir["conf/*"]
    libexec.install Dir["*.txt", "{bin,interface,javadoc,pylib,lib/licenses}"]
    libexec.install Dir["lib/*.jar"]
    bin.write_exec_script Dir["#{libexec}/bin/*"]
  end
end
