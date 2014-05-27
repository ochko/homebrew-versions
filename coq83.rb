require 'formula'

class TransitionalMode < Requirement
  def message; <<-EOS.undent
    camlp5 must be compiled in transitional mode (instead of --strict mode):
      brew install camlp5
    EOS
  end
  def satisfied?
    # If not installed, it will install in the correct mode.
    return true if not which('camlp5')
    # If installed, make sure it is transitional instead of strict.
    `camlp5 -pmode 2>&1`.chomp == 'transitional'
  end
  def fatal?
    true
  end
end

class Coq83 < Formula
  homepage 'http://coq.inria.fr/'
  url 'http://coq.inria.fr/distrib/V8.3pl5/files/coq-8.3pl5.tar.gz'
  version '8.3pl5'
  sha1 '16ace63137143f951b696fc779185f82cd2cb77e'

  depends_on TransitionalMode
  depends_on 'objective-caml'
  depends_on 'camlp5'

  def install
    camlp5_lib = "#{Formula["camlp5"].lib}/ocaml/camlp5"
    system "./configure", "-prefix", prefix,
                          "-mandir", man,
                          "-camlp5dir", camlp5_lib,
                          "-emacslib", "#{lib}/emacs/site-lisp",
                          "-coqdocdir", "#{share}/coq/latex",
                          "-coqide", "no",
                          "-with-doc", "no"
    ENV.j1 # Otherwise "mkdir bin" can be attempted by more than one job
    system "make world"
    system "make install"
  end

  def caveats; <<-EOS.undent
    Coq's Emacs mode is installed into
      #{lib}/emacs/site-lisp

    To use the Coq Emacs mode, you need to put the following lines in
    your .emacs file:
      (setq auto-mode-alist (cons '("\\.v$" . coq-mode) auto-mode-alist))
      (autoload 'coq-mode "coq" "Major mode for editing Coq vernacular." t)
    EOS
  end
end
