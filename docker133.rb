class Docker133 < Formula
  homepage "https://www.docker.com/"
  # Boot2docker and docker are generally updated at the same time.
  # Please update the version of boot2docker too
  url "https://github.com/docker/docker.git", :tag => "v1.3.3"

  bottle do
    cellar :any
    sha256 "d2c00b4eaab7bee413b79f1029f059b1f99d471c69b3d42b18bbc20c857fd5e7" => :yosemite
    sha256 "d363e371d854343bdb0fa5f898c13e02d6ab0921f164384ca8a42a7b0d379028" => :mavericks
    sha256 "f7a5eb3a0b5af7357fee4c4fcd061ecf554e6be460fe7d1f1c1e1238dc44b6fd" => :mountain_lion
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
