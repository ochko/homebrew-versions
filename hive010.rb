class Hive010 < Formula
  desc "Hadoop-based data summarization, query, and analysis"
  homepage "https://hive.apache.org"
  url "https://archive.apache.org/dist/hive/hive-0.10.0/hive-0.10.0-bin.tar.gz"
  sha256 "9a99ef0545758accaa30c0ede524bcaaaaeee12b115a9ca0ebf96fa72060abee"

  depends_on "hadoop"
  depends_on :java

  def install
    rm_f Dir["bin/*.bat"]
    libexec.install %w[bin conf examples lib ]
    libexec.install Dir["*.jar"]
    bin.write_exec_script Dir["#{libexec}/bin/*"]
  end

  def caveats; <<-EOS.undent
    Hadoop must be in your path for hive executable to work.
    After installation, set $HIVE_HOME in your profile:
      export HIVE_HOME=#{libexec}

    You may need to set JAVA_HOME:
      export JAVA_HOME="$(/usr/libexec/java_home)"
    EOS
  end
end
