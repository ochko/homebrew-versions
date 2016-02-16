class AndroidNdkR9d < Formula
  desc "Android native-code language toolset"
  homepage "https://developer.android.com/sdk/ndk/index.html"
  version "r9d"

  if MacOS.prefer_64_bit?
    url "https://dl.google.com/android/ndk/android-ndk-r9d-darwin-x86_64.tar.bz2"
    sha256 "4dc03dbd30dd98fee3664ebc48546b0ec40f9c2e184e4d9e97ce119e1b51b8a5"
  else
    url "https://dl.google.com/android/ndk/android-ndk-r9d-darwin-x86.tar.bz2"
    sha256 "82ee78e79fb049f099dcee6680e229339f4c5507308d67c9e145e0964d0b40af"
  end

  bottle :unneeded

  depends_on "android-sdk"

  def install
    bin.mkpath
    prefix.install Dir["*"]

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
