require 'formula'

class Scala29 < Formula
  homepage 'http://www.scala-lang.org/'
  url 'http://www.scala-lang.org/files/archive/scala-2.9.3.tgz'
  sha1 '01bf9e2c854e2385b2bcef319840415867a00388'

  keg_only 'Conflicts with scala in main repository.'

  option 'with-docs', 'Also install library documentation'

  resource 'docs' do
    url 'http://www.scala-lang.org/files/archive/scala-docs-2.9.3.zip'
    sha1 '633a31ca2eb87ce5b31b4f963bdfd1d4157282ad'
  end

  resource 'completion' do
    url 'https://raw.github.com/scala/scala-dist/27bc0c25145a83691e3678c7dda602e765e13413/completion.d/2.9.1/scala'
    sha1 'e2fd99fe31a9fb687a2deaf049265c605692c997'
  end

  def install
    rm_f Dir["bin/*.bat"]
    doc.install Dir['doc/*']
    man1.install Dir['man/man1/*']
    libexec.install Dir['*']
    bin.install_symlink Dir["#{libexec}/bin/*"]
    bash_completion.install resource('completion')
    doc.install resource('docs') if build.with? 'docs'
  end
end
