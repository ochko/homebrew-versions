class ApacheSpark121 < Formula
  desc "Engine for large-scale data processing"
  homepage "https://spark.apache.org/"
  url "https://d3kbcqa49mib13.cloudfront.net/spark-1.2.1-bin-hadoop2.4.tgz"
  version "1.2.1"
  sha256 "8e618cf67b3090acf87119a96e5e2e20e51f6266c44468844c185122b492b454"
  head "https://github.com/apache/spark.git"

  bottle :unneeded

  conflicts_with "hive", :because => "both install `beeline` binaries"
  conflicts_with "apache-spark", :because => "Both install the same binaries"

  def install
    rm_f Dir["bin/*.cmd"]
    libexec.install Dir["*"]
    bin.write_exec_script Dir["#{libexec}/bin/*"]
  end

  test do
    pipe_output("#{bin}/spark-shell", "sc.parallelize(1 to 1000).count()")
  end
end
