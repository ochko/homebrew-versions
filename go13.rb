class Go13 < Formula
  desc "Go programming environment (1.3)"
  homepage "https://golang.org"
  url "https://storage.googleapis.com/golang/go1.3.3.src.tar.gz"
  version "1.3.3"
  sha256 "1bb6fde89cfe8b9756a875af55d994cce0994861227b5dc0f268c143d91cd5ff"

  bottle do
    revision 1
    sha256 "d2c3c0b965390c3bc4f692d95310248e6b60bce2aa0837c0132edd54aa6de891" => :yosemite
    sha256 "dd5fda632d78f6aa217278b8969a82159b87bffb457f0db501dff99e4200b115" => :mavericks
    sha256 "6035b4eb2c551dc45c45af84e2b94723b69802eba0859ffda778ab17fae75f8c" => :mountain_lion
  end

  option "with-cc-all", "Build with cross-compilers and runtime support for all supported platforms"
  option "with-cc-common", "Build with cross-compilers and runtime support for darwin, linux and windows"
  option "without-cgo", "Build without cgo"
  option "without-godoc", "godoc will not be installed for you"
  option "without-vet", "vet will not be installed for you"

  deprecated_option "cross-compile-all" => "with-cc-all"
  deprecated_option "cross-compile-common" => "with-cc-common"

  resource "gotools" do
    url "https://go.googlesource.com/tools.git",
    :revision => "69db398fe0e69396984e3967724820c1f631e97"
  end

  def install
    # install the completion scripts
    bash_completion.install "misc/bash/go" => "go-completion.bash"
    zsh_completion.install "misc/zsh/go" => "go"

    # host platform (darwin) must come last in the targets list
    if build.with? "cc-all"
      targets = [
        ["linux",   ["386", "amd64", "arm"]],
        ["freebsd", ["386", "amd64"]],
        ["netbsd",  ["386", "amd64"]],
        ["openbsd", ["386", "amd64"]],
        ["windows", ["386", "amd64"]],
        ["darwin",  ["386", "amd64"]],
      ]
    elsif build.with? "cc-common"
      targets = [
        ["linux",   ["386", "amd64", "arm"]],
        ["windows", ["386", "amd64"]],
        ["darwin",  ["386", "amd64"]],
      ]
    else
      targets = [["darwin", [""]]]
    end

    cd "src" do
      targets.each do |os, archs|
        cgo_enabled = os == "darwin" && build.with?("cgo") ? "1" : "0"
        archs.each do |arch|
          ENV["GOROOT_FINAL"] = libexec
          ENV["GOOS"]         = os
          ENV["GOARCH"]       = arch
          ENV["CGO_ENABLED"]  = cgo_enabled
          ohai "Building go for #{arch}-#{os}"
          system "./make.bash", "--no-clean"
        end
      end
    end

    (buildpath/"pkg/obj").rmtree

    libexec.install Dir["*"]
    (bin/"go13").write_env_script(libexec/"bin/go", :PATH => "#{libexec}/bin:$PATH")
    bin.install_symlink libexec/"bin/gofmt" => "gofmt13"

    if build.with?("godoc") || build.with?("vet")
      ENV.prepend_path "PATH", libexec/"bin"
      ENV["GOPATH"] = buildpath
      (buildpath/"src/golang.org/x/tools").install resource("gotools")

      if build.with? "godoc"
        cd "src/golang.org/x/tools/cmd/godoc/" do
          system "go", "build"
          (libexec/"bin").install "godoc"
        end
        bin.install_symlink libexec/"bin/godoc" => "godoc13"
      end

      if build.with? "vet"
        cd "src/golang.org/x/tools/cmd/vet/" do
          system "go", "build"
          # This is where Go puts vet natively; not in the bin.
          (libexec/"pkg/tool/darwin_amd64/").install "vet"
        end
      end
    end
  end

  def caveats; <<-EOS.undent
    The `go*` commands in `bin` are suffixed with 13 e.g. `go13`.

    As of go 1.2, a valid GOPATH is required to use the `go get` command:
      https://golang.org/doc/code.html#GOPATH

    You may wish to add the GOROOT-based install location
    (with unsuffixed `go*` commands) to your PATH:
      export PATH=$PATH:#{opt_libexec}/bin
    EOS
  end

  test do
    (testpath/"hello.go").write <<-EOS.undent
    package main

    import "fmt"

    func main() {
        fmt.Println("Hello World")
    }
    EOS
    # Run go fmt check for no errors then run the program.
    # This is a a bare minimum of go working as it uses fmt, build, and run.
    system "#{bin}/go13", "fmt", "hello.go"
    assert_equal "Hello World\n", shell_output("#{bin}/go13 run hello.go")

    if build.with? "godoc"
      assert File.exist?(libexec/"bin/godoc")
      assert File.executable?(libexec/"bin/godoc")
    end

    if build.with? "vet"
      assert File.exist?(libexec/"pkg/tool/darwin_amd64/vet")
      assert File.executable?(libexec/"pkg/tool/darwin_amd64/vet")
    end
  end
end
