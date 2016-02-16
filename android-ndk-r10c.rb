class AndroidNdkR10c < Formula
  desc "Android native-code language toolset"
  homepage "https://developer.android.com/sdk/ndk/index.html"
  version "r10c"

  if MacOS.prefer_64_bit?
    url "https://dl.google.com/android/ndk/android-ndk-r10c-darwin-x86_64.bin"
    sha256 "420079521294dc81e532b34bb4ffe8c94c14dbad15696f0a662fbdbea298c17b"
  else
    url "https://dl.google.com/android/ndk/android-ndk-r10c-darwin-x86.bin"
    sha256 "19a7437a047a9200e40ec52bd5144b2492db0e1b7a5381c7988e645b42bf7d74"
  end

  bottle :unneeded

  depends_on "android-sdk" => :recommended

  def install
    bin.mkpath

    if MacOS.prefer_64_bit?
      chmod 0755, "./android-ndk-#{version}-darwin-x86_64.bin"
      system "./android-ndk-#{version}-darwin-x86_64.bin"
    else
      chmod 0755, "./android-ndk-#{version}-darwin-x86.bin"
      system "./android-ndk-#{version}-darwin-x86.bin"
    end

    # Now we can install both 64-bit and 32-bit targeting toolchains
    prefix.install Dir["android-ndk-#{version}/*"]

    # Create a dummy script to launch the ndk apps
    ndk_exec = prefix+"ndk-exec.sh"
    ndk_exec.write <<-EOS.undent
      #!/bin/sh
      BASENAME=`basename $0`
      EXEC="#{prefix}/$BASENAME"
      test -f "$EXEC" && exec "$EXEC" "$@"
    EOS
    ndk_exec.chmod 0755
    %w[ndk-build ndk-gdb ndk-stack].each { |app| bin.install_symlink ndk_exec => app }
  end

  def caveats; <<-EOS.undent
    We agreed to the Android NDK License Agreement for you by downloading the NDK.
    If this is unacceptable you should uninstall.

    License information at:
    https://developer.android.com/sdk/terms.html

    Software and System requirements at:
    https://developer.android.com/sdk/ndk/index.html#requirements

    For more documentation on Android NDK, please check:
      #{prefix}/docs
    EOS
  end
end
