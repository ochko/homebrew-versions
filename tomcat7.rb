class Tomcat7 < Formula
  desc "Implementation of Java Servlet and JavaServer Pages"
  homepage "https://tomcat.apache.org/"
  url "https://www.apache.org/dyn/closer.cgi?path=tomcat/tomcat-7/v7.0.67/bin/apache-tomcat-7.0.67.tar.gz"
  sha256 "cd6074f30e2cc98f55213fd396264a760f4a4c8a9b3d4842546578eab8f5220e"

  bottle :unneeded

  conflicts_with "tomcat", :because => "Differing versions of same formula"

  option "with-fulldocs", "Install full documentation locally"

  resource "fulldocs" do
    url "https://www.apache.org/dyn/closer.cgi?path=/tomcat/tomcat-7/v7.0.67/bin/apache-tomcat-7.0.67-fulldocs.tar.gz"
    version "7.0.67"
    sha256 "5d1b2977045d6ec9e29286c213f0b2947c95cb1ca7a4c9e590287a331587feec"
  end

  # Keep log folders
  skip_clean "libexec"

  def install
    # Remove Windows scripts
    rm_rf Dir["bin/*.bat"]

    # Install files
    prefix.install %w[NOTICE LICENSE RELEASE-NOTES RUNNING.txt]
    libexec.install Dir["*"]
    bin.install_symlink "#{libexec}/bin/catalina.sh" => "catalina"

    (share/"fulldocs").install resource("fulldocs") if build.with? "fulldocs"
  end
end
