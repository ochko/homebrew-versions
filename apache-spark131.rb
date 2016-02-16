class ApacheSpark131 < Formula
  desc "Engine for large-scale data processing"
  homepage "https://spark.apache.org/"
  url "https://d3kbcqa49mib13.cloudfront.net/spark-1.3.1-bin-hadoop2.6.tgz"
  version "1.3.1"
  sha256 "a25aaf58cfb3c64e3c77bdf9dde1a61247846d60519dd28b18d60d162d19c79a"

  bottle :unneeded

  conflicts_with "apache-spark", :because => "Differing version of same formula"

  def install
    # Rename beeline to distinguish it from hive's beeline
    mv "bin/beeline", "bin/spark-beeline"

    rm_f Dir["bin/*.cmd"]
    libexec.install Dir["*"]
    bin.write_exec_script Dir["#{libexec}/bin/*"]
  end

  test do
    system "#{bin}/spark-shell <<<'sc.parallelize(1 to 1000).count()'"
  end
end
