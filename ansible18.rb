class Ansible18 < Formula
  desc "A radically simple IT automation platform."
  homepage "http://www.ansible.com/home"
  url "http://releases.ansible.com/ansible/ansible-1.8.4.tar.gz"
  sha256 "d37c04b3abce9b036a6c8311fccb360c5cbc3ec895445f805243b0448d239ec1"

  bottle do
    sha256 "8193496e932476c379fc86054a689e0ac8c9bc67341c3ad1d8b230268b6d5d7c" => :yosemite
    sha256 "814e48e0ea8f68122ce649f6788dcc91cce9599a59ddab764470cd9e4cd9b24f" => :mavericks
    sha256 "75fcab04637b1a745f80c0837066ed2417f1df9c6402af6fb9a4bd8df2da1197" => :mountain_lion
  end

  depends_on :python if MacOS.version <= :snow_leopard
  depends_on "libyaml"

  conflicts_with "ansible", :because => "Differing versions of same formula"

  resource "docker-py" do
    url "https://pypi.python.org/packages/source/d/docker-py/docker-py-0.6.0.tar.gz"
    sha256 "937139fa439b1cfd81d31094962cbdb0cb8f4e27d87233d1b317a2758f631fe5"
  end

  resource "requests" do
    url "https://pypi.python.org/packages/source/r/requests/requests-2.6.0.tar.gz"
    sha256 "1cdbed1f0e236f35ef54e919982c7a338e4fea3786310933d3a7887a04b74d75"
  end

  resource "websocket-client" do
    url "https://pypi.python.org/packages/source/w/websocket-client/websocket-client-0.11.0.tar.gz"
    sha256 "3feeab76a7275dd1feda81977dd6897582f01e3d037e9d81e6d08648aa0f7060"
  end

  resource "six" do
    url "https://pypi.python.org/packages/source/s/six/six-1.8.0.tar.gz"
    sha256 "047bbbba41bac37c444c75ddfdf0573dd6e2f1fbd824e6247bb26fa7d8fa3830"
  end

  resource "pycrypto" do
    url "https://pypi.python.org/packages/source/p/pycrypto/pycrypto-2.6.tar.gz"
    sha256 "7293c9d7e8af2e44a82f86eb9c3b058880f4bcc884bf3ad6c8a34b64986edde8"
  end

  resource "boto" do
    url "https://pypi.python.org/packages/source/b/boto/boto-2.36.0.tar.gz"
    sha256 "8033c6f7a7252976df0137b62536cfe38f1dbd1ef443a7a6d8bc06c063bc36bd"
  end

  resource "pyyaml" do
    url "https://pypi.python.org/packages/source/P/PyYAML/PyYAML-3.10.tar.gz"
    sha256 "e713da45c96ca53a3a8b48140d4120374db622df16ab71759c9ceb5b8d46fe7c"
  end

  resource "paramiko" do
    url "https://pypi.python.org/packages/source/p/paramiko/paramiko-1.11.0.tar.gz"
    sha256 "d46fb8af4c4ffca3c55c600c17354c7c149d8c5dcd7cd6395f4fa0ce2deaca87"
  end

  resource "markupsafe" do
    url "https://pypi.python.org/packages/source/M/MarkupSafe/MarkupSafe-0.18.tar.gz"
    sha256 "b7d5d688bdd345bfa897777d297756688cf02e1b3742c56885e2e5c2b996ff82"
  end

  resource "jinja2" do
    url "https://pypi.python.org/packages/source/J/Jinja2/Jinja2-2.7.1.tar.gz"
    sha256 "5cc0a087a81dca1c08368482fb7a92fe2bdd8cfbb22bc0fccfe6c85affb04c8b"
  end

  resource "pyasn1" do
    url "https://pypi.python.org/packages/source/p/pyasn1/pyasn1-0.1.7.tar.gz"
    sha256 "e4f81d53c533f6bd9526b047f047f7b101c24ab17339c1a7ad8f98b25c101eab"
  end

  resource "python-keyczar" do
    url "https://pypi.python.org/packages/source/p/python-keyczar/python-keyczar-0.71c.tar.gz"
    sha256 "37707db2af3dde1c7e087b8a8f72ce3bef376889a3a358a72fe66e83318fb0a2"
  end

  resource "pywinrm" do
    url "https://pypi.python.org/packages/source/p/pywinrm/pywinrm-0.0.3.tar.gz"
    sha256 "be3775890effcddfb1fca440b43bf08af165527a7b102d43518232bfc9c021bc"
  end

  resource "isodate" do
    url "https://pypi.python.org/packages/source/i/isodate/isodate-0.5.0.tar.gz"
    sha256 "f3e436a9c321882942a6c62e9d8ea49787b4c0ea7f7bb3cbd047bcf76bd0dfbe"
  end

  resource "xmltodict" do
    url "https://pypi.python.org/packages/source/x/xmltodict/xmltodict-0.9.0.tar.gz"
    sha256 "cc506d660e1d231efa9b766f88cec2ced05394ce94adabddf7b149da7712e719"
  end

  def install
    ENV["PYTHONPATH"] = libexec/"vendor/lib/python2.7/site-packages"
    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"

    res = %w[pycrypto boto pyyaml paramiko markupsafe jinja2]
    res += %w[isodate xmltodict pywinrm] # windows support
    res += %w[six requests websocket-client docker-py] # docker support
    res += %w[pyasn1 python-keyczar] # accelerate support
    res.each do |r|
      resource(r).stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    inreplace "lib/ansible/constants.py" do |s|
      s.gsub! "/usr/share/ansible", share/"ansible"
      s.gsub! "/etc/ansible", etc/"ansible"
    end

    system "python", *Language::Python.setup_install_args(libexec)

    man1.install Dir["docs/man/man1/*.1"]
    bin.install Dir["#{libexec}/bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    ENV["ANSIBLE_REMOTE_TEMP"] = testpath/"tmp"
    (testpath/"playbook.yml").write <<-EOF.undent
      ---
      - hosts: all
        gather_facts: False
        tasks:
        - name: ping
          ping:
    EOF
    (testpath/"hosts.ini").write("localhost ansible_connection=local\n")
    system bin/"ansible-playbook", testpath/"playbook.yml", "-i", testpath/"hosts.ini"
  end
end
