class Gradle21 < Formula
  desc "Build system based on the Groovy language"
  homepage "https://www.gradle.org/"
  url "https://downloads.gradle.org/distributions/gradle-2.1-bin.zip"
  sha256 "3eee4f9ea2ab0221b89f8e4747a96d4554d00ae46d8d633f11cfda60988bf878"

  bottle :unneeded

  conflicts_with "gradle", :because => "Differing version of same formula"

  def install
    libexec.install %w[bin lib]
    bin.install_symlink libexec+"bin/gradle"
  end

  test do
    ENV["GRADLE_USER_HOME"] = testpath
    assert_match "Gradle #{version}", shell_output("#{bin}/gradle --version")
  end
end
