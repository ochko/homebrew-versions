require 'formula'

class Squid2 < Formula
  homepage 'http://www.squid-cache.org/'
  url 'http://www.squid-cache.org/Versions/v2/2.7/squid-2.7.STABLE9.tar.gz'
  version '2.7.9'
  sha1 '6d90fe06468b662b2eefd7ffeb47b9a78f0a871d'

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--localstatedir=#{var}/squid"
    system "make install"

    # Create default Squid cache and log dirs
    (var/'squid/cache').mkpath
    (var/'squid/logs').mkpath
    # Create swap directories otherwise squid will complain
    system "#{sbin}/squid", "-z"
  end
end
