class Grails20 < Formula
  desc "Web application framework for the Groovy language"
  homepage "http://grails.org"
  url "http://dist.springframework.org.s3.amazonaws.com/release/GRAILS/grails-2.0.4.zip"
  sha256 "51a273b8d51c08a21111bba774745db70370fbe7df906dba5551da2376f4f41b"

  bottle :unneeded

  # Grails 2.0.x doesn't support Java 8
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
