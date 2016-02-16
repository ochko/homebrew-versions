class Grails23 < Formula
  desc "Web application framework for the Groovy language"
  homepage "http://grails.org"
  url "http://dist.springframework.org.s3.amazonaws.com/release/GRAILS/grails-2.3.11.zip"
  sha256 "c53e01a9d98c499f91d7c7d54312dbdfd33f99ffcdec8bc4946036e4bea2c8e1"

  bottle :unneeded

  depends_on :java

  def install
    rm_f Dir["bin/*.bat", "bin/cygrails", "*.bat"]
    prefix.install %w[LICENSE README]
    libexec.install Dir["*"]
    bin.mkpath
    Dir["#{libexec}/bin/*"].each do |f|
      next unless File.extname(f).empty?
      ln_s f, bin+File.basename(f)
    end
  end

  test do
    ENV["JAVA_HOME"] = `/usr/libexec/java_home`.chomp
    assert_match "Grails version: #{version}",
      shell_output("#{bin}/grails --version")
  end
end
