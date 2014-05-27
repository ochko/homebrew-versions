require 'formula'

class Perl518 < Formula
  homepage 'http://www.perl.org/'
  url 'http://www.cpan.org/src/5.0/perl-5.18.2.tar.gz'
  sha1 '7f0cc08d883a0e0aaaa385903ec4fb28aec514ec'

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
