class JenkinsLts < Formula
  desc "Extendable open-source CI server"
  homepage "http://jenkins-ci.org/#stable"
  url "http://mirrors.jenkins-ci.org/war-stable/1.642.1/jenkins.war"
  sha256 "ce036e227fe1fed15e3da9be8d29e859bdcda7118895fd269d1c9ac35925de66"

  depends_on :java => "1.7+"

  conflicts_with "jenkins",
    :because => "both use the same data directory: $HOME/.jenkins"

  def install
    system "jar", "xvf", "jenkins.war"
    libexec.install Dir["jenkins.war", "WEB-INF/jenkins-cli.jar"]
    bin.write_jar_script libexec/"jenkins.war", "jenkins-lts"
    bin.write_jar_script libexec/"jenkins-cli.jar", "jenkins-lts-cli"
  end

  plist_options :manual => "jenkins-lts"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>/usr/bin/java</string>
          <string>-Dmail.smtp.starttls.enable=true</string>
          <string>-jar</string>
          <string>#{opt_libexec}/jenkins.war</string>
          <string>--httpListenAddress=127.0.0.1</string>
          <string>--httpPort=8080</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
      </dict>
    </plist>
    EOS
  end

  def caveats; <<-EOS.undent
    Note: When using launchctl the port will be 8080.
    EOS
  end

  test do
    ENV["JENKINS_HOME"] = testpath
    pid = fork do
      exec "#{bin}/jenkins-lts"
    end
    sleep 60

    begin
      assert_match /"mode":"NORMAL"/, shell_output("curl localhost:8080/api/json")
    ensure
      Process.kill("SIGINT", pid)
      Process.wait(pid)
    end
  end
end
