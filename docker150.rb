class Docker150 < Formula
  homepage "https://www.docker.com/"
  url "https://github.com/docker/docker.git",
      :tag => "v1.5.0",
      :revision => "a8a31eff10544860d2188dddabdee4d727545796"

  bottle do
    cellar :any
    sha256 "2256ee87c0119e6103017426be424fe90c7c5a6c04db41b74c8d92878063cb4a" => :yosemite
    sha256 "b324f9255ec8cd89955a149104953c8358ced91163c52caa798802ecb39e871c" => :mavericks
    sha256 "9f7aa93fee84ef44080e9b72e654b98189aae3c68731582d8d06cd9b305f07ee" => :mountain_lion
  end

  option "without-completions", "Disable bash/zsh completions"

  depends_on "go" => :build

  def install
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
