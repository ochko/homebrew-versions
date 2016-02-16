class BashCompletion2 < Formula
  homepage "https://bash-completion.alioth.debian.org/"
  url "https://mirrors.kernel.org/debian/pool/main/b/bash-completion/bash-completion_2.1.orig.tar.bz2"
  mirror "https://mirrors.ocf.berkeley.edu/debian/pool/main/b/bash-completion/bash-completion_2.1.orig.tar.bz2"
  sha256 "2b606804a7d5f823380a882e0f7b6c8a37b0e768e72c3d4107c51fbe8a46ae4f"
  revision 2

  bottle do
    cellar :any
    revision 1
    sha256 "914804199dc8adf2e3e6522fc60a1ec76c502167c946bc95a6ad2fdda5d4f54e" => :yosemite
    sha256 "237eec834214fe7dd6b40b262af906165a376c771bf364b0a572443688fd7f00" => :mavericks
    sha256 "a0913ef676c878af34c2c5fc57e0337aadcb0634a45fac6a8066039996ada5f5" => :mountain_lion
  end

  conflicts_with "bash-completion"

  # All three fix issues with GNU extended regexs
  patch do
    url "https://anonscm.debian.org/gitweb/?p=bash-completion/bash-completion.git;a=patch;h=f230cfddbd12b8c777040e33bac1174c0e2898af"
    sha256 "b557b2f71a1376b51bf2de1c56f181b27111381cb3cac727144d65d94ab1758a"
  end

  patch do
    url "https://anonscm.debian.org/gitweb/?p=bash-completion/bash-completion.git;a=patch;h=3ac523f57e8d26e0943dfb2fd22f4a8879741c60"
    sha256 "b680b347d8f1330cbae47b76ec6d9e9ec15459a7c89c2c767855e47afbebed96"
  end

  patch do
    url "https://anonscm.debian.org/gitweb/?p=bash-completion/bash-completion.git;a=patch;h=50ae57927365a16c830899cc1714be73237bdcb2"
    sha256 "7a5dda29cb0c0ba4fc747fd2163c8041efe4b157b71708b4e9db5a0048588e6b"
  end

  # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=739835
  # resolves issue with completion of files/directories with spaces in the name.
  patch do
    url "https://anonscm.debian.org/cgit/bash-completion/debian.git/plain/debian/patches/00-fix_quote_readline_by_ref.patch?id=d734ca3bd73ae49b8f452802fb8fb65a440ab07a"
    sha256 "7304f8fb4ad869f1b3d6f3456b2750246ddedef6fc307939bf403bf528f2fdf1"
  end

  # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=739835
  # https://bugs.launchpad.net/ubuntu/+source/bash-completion/+bug/1289597
  patch :DATA

  def compdir
    HOMEBREW_PREFIX/"share/bash-completion/completions"
  end

  def install
    inreplace "bash_completion", "readlink -f", "readlink"

    system "./configure", "--prefix=#{prefix}", "--sysconfdir=#{etc}"
    ENV.deparallelize
    system "make", "install"
  end

  def post_install
    compdir.realpath.install_symlink HOMEBREW_CONTRIB/"brew_bash_completion.sh" => "brew"
  end

  def caveats; <<-EOS.undent
    Add the following to your ~/.bash_profile:
      if [ -f $(brew --prefix)/share/bash-completion/bash_completion ]; then
        . $(brew --prefix)/share/bash-completion/bash_completion
      fi

      Homebrew's own bash completion script has been linked into
        #{compdir}
      bash-completion will automatically source it when you invoke `brew`.

      Any completion scripts in #{Formula["bash-completion"].compdir}
      will continue to be sourced as well.
    EOS
  end
end

__END__
diff --git a/bash_completion b/bash_completion
index 6d3ba76..5d9c645 100644
--- a/bash_completion
+++ b/bash_completion
@@ -707,7 +707,7 @@ _init_completion()
         fi
     done
 
-    [[ $cword -eq 0 ]] && return 1
+    [[ $cword -le 0 ]] && return 1
     prev=${words[cword-1]}
 
     [[ ${split-} ]] && _split_longopt && split=true
