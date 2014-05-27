require 'formula'

class Perl514 < Formula
  homepage 'http://www.perl.org/'
  url 'http://www.cpan.org/src/5.0/perl-5.14.4.tar.gz'
  sha1 '2fdbbf39b3bbd79e42a7cf42fc05bf9891f077a1'

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
