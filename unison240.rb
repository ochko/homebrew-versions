class Unison240 < Formula
  desc "Unison file synchronizer"
  homepage "http://www.cis.upenn.edu/~bcpierce/unison/"
  url "http://www.seas.upenn.edu/~bcpierce/unison/download/releases/unison-2.40.128/unison-2.40.128.tar.gz"
  sha256 "5a1ea828786b9602f2a42c2167c9e7643aba2c1e20066be7ce46de4779a5ca54"

  bottle do
    cellar :any
    sha256 "f7934fb365bb6d8267b9f10d7f42846dff6614fe517cc52d6c8eac85dc5f8e82" => :yosemite
    sha256 "68eb2b262e62fb0127c17285d98c180a644754a9ca14a60166ee15477d43c4de" => :mavericks
    sha256 "062468878d77d8e2101d4a95775725a10d61265d34100153011c739164b6ce6f" => :mountain_lion
  end

  depends_on "objective-caml" => :build

  def install
    ENV.j1
    ENV.delete "CFLAGS" # ocamlopt reads CFLAGS but doesn't understand common options
    ENV.delete "NAME" # https://github.com/Homebrew/homebrew/issues/28642
    system "make", "./mkProjectInfo"
    system "make", "UISTYLE=text"
    bin.install "unison"
  end

  test do
    system bin/"unison", "-version"
  end
end
