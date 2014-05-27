require 'formula'

class BashCompletion2 < Formula
  homepage 'http://bash-completion.alioth.debian.org/'
  url 'http://ftp.de.debian.org/debian/pool/main/b/bash-completion/bash-completion_2.1.orig.tar.bz2'
  sha256 '2b606804a7d5f823380a882e0f7b6c8a37b0e768e72c3d4107c51fbe8a46ae4f'

  conflicts_with 'bash-completion'

  # All three fix issues with GNU extended regexs
  def patches
    ["http://anonscm.debian.org/gitweb/?p=bash-completion/bash-completion.git;a=patch;h=f230cfddbd12b8c777040e33bac1174c0e2898af",
     "http://anonscm.debian.org/gitweb/?p=bash-completion/bash-completion.git;a=patch;h=3ac523f57e8d26e0943dfb2fd22f4a8879741c60",
     "http://anonscm.debian.org/gitweb/?p=bash-completion/bash-completion.git;a=patch;h=50ae57927365a16c830899cc1714be73237bdcb2"]
  end

  def compdir
    HOMEBREW_PREFIX/'share/bash-completion/completions'
  end

  def install
    inreplace 'bash_completion', 'readlink -f', 'readlink'

    system "./configure", "--prefix=#{prefix}", "--sysconfdir=#{etc}"
    ENV.deparallelize
    system "make install"

    unless (compdir/'brew').exist?
      compdir.install_symlink HOMEBREW_CONTRIB/'brew_bash_completion.sh' => 'brew'
    end
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
