require 'formula'

class PythonVersion < Requirement
  env :userpaths

  satisfy { `python -c 'import sys;print(sys.version[:3])'`.strip.to_f >= 2.6 }

  def message;
    "Node's build system, gyp, requires Python 2.6 or newer."
  end
end

class NpmNotInstalled < Requirement
  fatal true

  def modules_folder
    "#{HOMEBREW_PREFIX}/lib/node_modules"
  end

  def message; <<-EOS.undent
    The homebrew node recipe now (beginning with 0.8.0) comes with npm.
    It appears you already have npm installed at #{modules_folder}/npm.
    To use the npm that comes with this recipe,
      first uninstall npm with `npm uninstall npm -g`.
      Then run this command again.

    If you would like to keep your installation of npm instead of
      using the one provided with homebrew,
      install the formula with the --without-npm option added.
    EOS
  end

  satisfy :build_env => false do
    begin
      path = Pathname.new("#{modules_folder}/npm/bin/npm")
      path.realpath.to_s.include?(HOMEBREW_CELLAR)
    rescue Errno::ENOENT
      true
    end
  end
end

class Node08 < Formula
  homepage 'http://nodejs.org/'
  url 'http://nodejs.org/dist/v0.8.26/node-v0.8.26.tar.gz'
  sha1 '2ec960bcc8cd38da271f83c1b2007c12da5153b3'

  option 'enable-debug', 'Build with debugger hooks'
  option 'without-npm', 'npm will not be installed'
  option 'with-shared-libs', 'Use Homebrew V8 and system OpenSSL, zlib'

  depends_on NpmNotInstalled if build.with? 'npm'
  depends_on PythonVersion
  depends_on 'v8' if build.with? 'shared-libs'

  fails_with :llvm do
    build 2326
  end

  # Fixes double-free issue. See https://github.com/joyent/node/issues/6427
  # Should be fixed if they ever do a v0.8 release.
  patch :p1, :DATA

  def install
    # Lie to `xcode-select` for now to work around a GYP bug that affects
    # CLT-only systems:
    #
    #   http://code.google.com/p/gyp/issues/detail?id=292
    #   joyent/node#3681
    ENV['DEVELOPER_DIR'] = MacOS.dev_tools_path unless MacOS::Xcode.installed?

    args = %W{--prefix=#{prefix}}

    if build.with? 'shared-libs'
      args << '--shared-openssl' unless MacOS.version == :leopard
      args << '--shared-v8'
      args << '--shared-zlib'
    end

    args << "--debug" if build.include? 'enable-debug'
    args << "--without-npm" if build.without? 'npm'

    system "./configure", *args
    system "make install"

    if build.with? 'npm'
      (lib/"node_modules/npm/npmrc").write(npmrc)
    end
  end

  def npm_prefix
    "#{HOMEBREW_PREFIX}/share/npm"
  end

  def npm_bin
    "#{npm_prefix}/bin"
  end

  def modules_folder
    "#{HOMEBREW_PREFIX}/lib/node_modules"
  end

  def npmrc
    <<-EOS.undent
      prefix = #{npm_prefix}
    EOS
  end

  def caveats
    if build.without? 'npm'
      <<-EOS.undent
        Homebrew has NOT installed npm. We recommend the following method of
        installation:
          curl https://npmjs.org/install.sh | sh

        After installing, add the following path to your NODE_PATH environment
        variable to have npm libraries picked up:
          #{modules_folder}
      EOS
    elsif not ENV['PATH'].split(':').include? npm_bin
      <<-EOS.undent
        Homebrew installed npm.
        We recommend prepending the following path to your PATH environment
        variable to have npm-installed binaries picked up:
          #{npm_bin}
      EOS
    end
  end
end
__END__
diff --git a/deps/v8/src/spaces.h b/deps/v8/src/spaces.h
index b0ecc5d..d76d77d 100644
--- a/deps/v8/src/spaces.h
+++ b/deps/v8/src/spaces.h
@@ -321,7 +321,8 @@ class MemoryChunk {
   Space* owner() const {
     if ((reinterpret_cast<intptr_t>(owner_) & kFailureTagMask) ==
         kFailureTag) {
-      return reinterpret_cast<Space*>(owner_ - kFailureTag);
+      return reinterpret_cast<Space*>(reinterpret_cast<intptr_t>(owner_) -
+                                      kFailureTag);
     } else {
       return NULL;
     }
