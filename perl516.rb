require 'formula'

class Perl516 < Formula
  homepage 'http://www.perl.org/'
  url 'http://www.cpan.org/src/5.0/perl-5.16.3.tar.gz'
  sha1 '83678adf56d3dc51f47a90444a891f4fe16868da'

  keg_only 'System provides Perl. Also conflicts with other Perl versions.'

  option 'use-dtrace', 'Build with DTrace probes'

  def install
    args = [
      '-des',
      "-Dprefix=#{prefix}",
      "-Dman1dir=#{man1}",
      "-Dman3dir=#{man3}",
      '-Duseshrplib',
      '-Duselargefiles',
      '-Dusethreads'
    ]

    args << '-Dusedtrace' if build.include? 'use-dtrace'

    system './Configure', *args
    system "make"
    system "make test"
    system "make install"
  end
end
