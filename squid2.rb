class Squid2 < Formula
  desc "Proxy caching server for HTTP(S), FTP, and Gopher"
  homepage "http://www.squid-cache.org/"
  url "http://www.squid-cache.org/Versions/v2/2.7/squid-2.7.STABLE9.tar.gz"
  version "2.7.9"
  sha256 "d54ca048313c4b64609fcdf9f1934a70fc1702032a5f04073056d7491d3dd781"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--localstatedir=#{var}/squid"
    system "make", "install"

    # Create default Squid cache and log dirs
    (var/"squid/cache").mkpath
    (var/"squid/logs").mkpath
    # Create swap directories otherwise squid will complain
    system "#{sbin}/squid", "-z"
  end
end
