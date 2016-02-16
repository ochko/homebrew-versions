class Maven2 < Formula
  desc "Java-based project management"
  homepage "https://maven.apache.org/"
  url "https://archive.apache.org/dist/maven/binaries/apache-maven-2.2.1-bin.tar.gz"
  sha256 "b9a36559486a862abfc7fb2064fd1429f20333caae95ac51215d06d72c02d376"

  conflicts_with "maven", :because => "Differing versions of same formula"

  depends_on :java

  def install
    # Remove windows files
    rm_f Dir["bin/*.bat"]

    # Install jars in libexec to avoid conflicts
    prefix.install %w[NOTICE.txt LICENSE.txt README.txt]
    libexec.install Dir["*"]

    # Symlink binaries
    bin.mkpath
    Dir["#{libexec}/bin/*"].each do |f|
      ln_s f, bin+File.basename(f)
    end
  end
end
