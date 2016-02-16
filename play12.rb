class Play12 < Formula
  homepage "http://www.playframework.org/"
  url "http://downloads.typesafe.com/play/1.2.7.2/play-1.2.7.2.zip"
  sha256 "4fc610e2db0993fee3daf01527ba5ca57a9ad970c429733415ee59b55064b322"

  bottle do
    cellar :any
    sha256 "cb17a08dc698a1a67715f7e84c6fe22976b5504b165caf237f608c8efc2cc33c" => :yosemite
    sha256 "dd9edaea771dde63964f647f6b49cff8714fe70598cf128a59ce59bcd4381925" => :mavericks
    sha256 "d268067627b29e3d955b1923af64884833b112e8accdee4c515a1862258f1d49" => :mountain_lion
  end

  conflicts_with "sox", :because => "Both install a `play` executable"

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
