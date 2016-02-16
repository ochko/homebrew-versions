class Nettle3 < Formula
  desc "Low-level cryptographic library"
  homepage "https://www.lysator.liu.se/~nisse/nettle/"
  url "http://ftpmirror.gnu.org/nettle/nettle-3.1.1.tar.gz"
  mirror "https://ftp.gnu.org/gnu/nettle/nettle-3.1.1.tar.gz"
  sha256 "5fd4d25d64d8ddcb85d0d897572af73b05b4d163c6cc49438a5bfbb8ff293d4c"

  bottle do
    cellar :any
    revision 1
    sha256 "79a067bb298e58733ac4dae8f28cdc5b09af94b068e75f7051f2fce54bfa302b" => :el_capitan
    sha256 "0c42176d5cef0ddfce8fcaa15cf733d87e85874895902ecfc68afeedd723b62c" => :yosemite
    sha256 "57d8353f6245063cf2d232be5e9bf33a230751f073d232af97a0473b54d67a32" => :mavericks
  end

  depends_on "gmp"

  keg_only "Conflicts with nettle in main repository"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-shared"
    system "make"
    system "make", "install"
    system "make", "check"
  end

  test do
    (testpath/"testfile.txt").write("This is a test file")
    expected = /91b7b0b1e27bfbf7 bc646946f35fa972 c47c2d32/

    assert_match expected, shell_output("#{bin}/nettle-hash --a sha1 testfile.txt")
  end
end
