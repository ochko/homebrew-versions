class Docker141 < Formula
  homepage "https://www.docker.com/"
  url "https://github.com/docker/docker.git", :tag => "v1.4.1"

  bottle do
    cellar :any
    sha256 "20164f5f8f36a20032530b05cc5fe2eca53da8b9591a351da8e923410751bb89" => :yosemite
    sha256 "8fab0f97f72dc1d27db2da12c4ba5893aec100bee0e10ef81f7597f81cac790a" => :mavericks
    sha256 "0366d2587450b32d00401b5d6e166693a095d74265223d958cf509a2757761df" => :mountain_lion
  end

  option "without-completions", "Disable bash/zsh completions"

  depends_on "go" => :build

  def install
    ENV["GIT_DIR"] = cached_download/".git"
    ENV["AUTO_GOPATH"] = "1"
    ENV["DOCKER_CLIENTONLY"] = "1"

    system "hack/make.sh", "dynbinary"
    bin.install "bundles/#{version}/dynbinary/docker-#{version}" => "docker"

    if build.with? "completions"
      bash_completion.install "contrib/completion/bash/docker"
      zsh_completion.install "contrib/completion/zsh/_docker"
    end
  end

  test do
    system "#{bin}/docker", "--version"
  end
end
