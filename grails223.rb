class Grails223 < Formula
  desc "Web application framework for the Groovy language"
  homepage "http://grails.org"
  url "http://dist.springframework.org.s3.amazonaws.com/release/GRAILS/grails-2.2.3.zip"
  sha256 "af084206cb134c50cd52e93cd7abb056e55488a8712d247af0d8a60234cdd43a"

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
