class Libdvdcss12 < Formula
  homepage "https://www.videolan.org/developers/libdvdcss.html"
  url "https://download.videolan.org/pub/libdvdcss/1.2.13/libdvdcss-1.2.13.tar.bz2"
  sha256 "84f1bba6cfef1df87f774fceaefc8e73c4cda32e8f6700b224ad0acb5511ba2c"

  bottle do
    cellar :any
    sha256 "4069c609642a8db093211c5ac84146645f7423c05852f47bc64c89c741ea1f0f" => :yosemite
    sha256 "14712b601bf80411fa3c99fbf06a0617a533599c0ac5a07a98d6cc09d4305470" => :mavericks
    sha256 "0dac101f611520c3eaf5527d928865a88192be8e6922249c789309b6ef21ae5f" => :mountain_lion
  end

  def install
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make", "install"
  end
end

