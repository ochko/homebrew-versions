class Grails224 < Formula
  desc "Web application framework for the Groovy language"
  homepage "http://grails.org"
  url "http://dist.springframework.org.s3.amazonaws.com/release/GRAILS/grails-2.2.4.zip"
  sha256 "7453eb23856f4b1acad4b084990f748494b260eb18dfbcdf0c4a28c2f54ce92f"

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
