class Grails21 < Formula
  desc "Web application framework for the Groovy language"
  homepage "http://grails.org"
  url "http://dist.springframework.org.s3.amazonaws.com/release/GRAILS/grails-2.1.4.zip"
  sha256 "10d0b8929ce01b03db851ffee92ab30f67c12abd6541ff78fb412f901c57642f"

  bottle :unneeded

  # Grails 2.1.x doesn't support Java 8
  depends_on :java => "1.7"

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
      shell_output("#{bin}/grails --version", 1)
  end
end
