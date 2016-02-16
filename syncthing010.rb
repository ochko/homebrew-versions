class Syncthing010 < Formula
  homepage "https://syncthing.net/"
  url "https://github.com/syncthing/syncthing.git",
      :tag => "v0.10.31",
      :revision => "2470875d1436a1757e07bec09e388b75d5ac12c0"

  bottle do
    cellar :any
    sha256 "acea7eb8d47d40de31719437e9d12f74a0f76be0df97f33c5cedc07a5a6e4246" => :yosemite
    sha256 "48ce978c9eec4f574517e410527eee37189a11a0db2bcbabcef3d3b10a581672" => :mavericks
    sha256 "623b069e7a658c7760606fb9adfacb810c9b80e4c383d2cde780177644bfe92c" => :mountain_lion
  end

  depends_on "go" => :build
  depends_on :hg => :build

  conflicts_with "syncthing", :because => "Differing versions of the same formulae."

  def install
    ENV["GOPATH"] = cached_download/".gopath"
    ENV.append_path "PATH", "#{ENV["GOPATH"]}/bin"

    # FIXTHIS: do this without mutating the cache!
    hack_dir = cached_download/".gopath/src/github.com/syncthing"
    rm_rf hack_dir
    mkdir_p hack_dir
    ln_s cached_download, "#{hack_dir}/syncthing"

    system "./build.sh", "noupgrade"
    bin.install "syncthing"
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <true/>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/syncthing</string>
          <string>-no-browser</string>
          <string>-no-restart</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>ProcessType</key>
        <string>Background</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/syncthing010.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/syncthing010.log</string>
      </dict>
    </plist>
    EOS
  end

  test do
    system bin/"syncthing", "-generate", "./"
  end
end
