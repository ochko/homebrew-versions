class Play13 < Formula
  homepage "https://www.playframework.org/"
  url "https://github.com/playframework/play1/releases/download/1.3.2/play-1.3.2.zip"
  sha256 "b88e99fa4ab64c4efe4f87adeb48522f6d5d0397397cd4d7fd1937b8ce51f44c"

  bottle :unneeded

  conflicts_with "sox", :because => "Both install a `play` executable"
  conflicts_with "play12", :because => "Both install a `play` executable"
  conflicts_with "play22", :because => "Both install a `play` executable"

  def install
    rm_rf "python" # we don't need the bundled Python for windows
    rm Dir["*.bat"]
    libexec.install Dir["*"]
    chmod 0755, libexec/"play"
    bin.install_symlink libexec/"play"
  end

  test do
    require "open3"
    Open3.popen3("#{bin}/play new #{testpath}/app") do |stdin, _, _|
      stdin.write "\n"
      stdin.close
    end
    %W[app conf lib public test].each do |d|
      File.directory? testpath/"app/#{d}"
    end
  end
end
