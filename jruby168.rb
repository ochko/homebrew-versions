class Jruby168 < Formula
  desc "Ruby implementation in pure Java"
  homepage "http://www.jruby.org"
  url "https://s3.amazonaws.com/jruby.org/downloads/1.6.8/jruby-bin-1.6.8.tar.gz"
  sha256 "e3b05f9cf0ba9b02e6cba75d5b62e2abf8ac7a4483c3713dc4eb83e3b8b162d4"

  depends_on :java => "1.7+"

  conflicts_with "jruby", :because => "Differing version of the same formula"
  conflicts_with "jruby1721", :because => "Differing version of the same formula"
  conflicts_with "jruby9000", :because => "Differing version of the same formula"

  def install
    # Remove Windows files
    rm Dir["bin/*.{bat,dll,exe}"]

    cd "bin" do
      # Prefix a 'j' on some commands to avoid clashing with other rubies
      %w[ast rake rdoc ri testrb].each { |f| mv f, "j#{f}" }
      # Delete some unnecessary commands
      rm "gem" # gem is a wrapper script for jgem
      rm "irb" # irb is an identical copy of jirb
    end

    # Only keep the OS X native libraries
    rm_rf Dir["lib/jni/*"] - ["lib/jni/Darwin"]
    libexec.install Dir["*"]
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system "#{bin}/jruby", "-e", "puts 'hello'"
  end
end
