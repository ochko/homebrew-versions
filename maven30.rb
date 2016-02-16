class Maven30 < Formula
  desc "Java-based project management"
  homepage "https://maven.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=maven/maven-3/3.0.5/binaries/apache-maven-3.0.5-bin.tar.gz"
  sha256 "d98d766be9254222920c1d541efd466ae6502b82a39166c90d65ffd7ea357dd9"

  conflicts_with "maven", :because => "Differing versions of same formula"

  depends_on :java

  def install
    # Remove windows files
    rm_f Dir["bin/*.bat"]

    # Fix the permissions on the global settings file.
    chmod 0644, "conf/settings.xml"

    prefix.install_metafiles
    libexec.install Dir["*"]
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end
end
