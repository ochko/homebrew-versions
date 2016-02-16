class Boot2docker162 < Formula
  desc "boot2docker runs Docker containers on OSX"
  homepage "https://github.com/boot2docker/boot2docker-cli"
  url "https://github.com/boot2docker/boot2docker-cli.git",
      :tag => "v1.6.2",
      :revision => "cb2c3bcc890d8ee67bb76cc91ecf5b63927c97f9"

  bottle do
    cellar :any
    sha256 "8fc53a91e70cffa85c027eeff13e7cacb75e3ee972bb1b48269b60e72a7753b5" => :yosemite
    sha256 "75f77bec6752e476cbb3cc86af294577fcfe8c100a86a188adfe777fe17f1524" => :mavericks
    sha256 "8e206a8bda71f95a7408ad7c18d1f76768a01b781517c05234755f9c16f5f4e0" => :mountain_lion
  end

  depends_on "docker162" => :recommended
  depends_on "go" => :build

  conflicts_with "boot2docker", :because => "Differing version of the same formula"

  def install
    (buildpath + "src/github.com/boot2docker/boot2docker-cli").install Dir[buildpath/"*"]

    cd "src/github.com/boot2docker/boot2docker-cli" do
      ENV["GOPATH"] = buildpath
      system "go", "get", "-d"

      ENV["GIT_DIR"] = cached_download/".git"
      system "make", "goinstall"
    end

    bin.install "bin/boot2docker-cli" => "boot2docker"
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_bin}/boot2docker</string>
        <string>up</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
    </dict>
    </plist>
    EOS
  end

  test do
    system "#{bin}/boot2docker", "version"
  end
end
