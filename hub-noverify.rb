# original: https://gist.github.com/aereal/ef28321cdee48d987025
class HubNoverify < Formula
  desc "Add GitHub support to git on the command-line"
  homepage "https://hub.github.com/"
  url "https://github.com/github/hub/archive/v2.2.1.tar.gz"
  sha256 "9350aba6a8e3da9d26b7258a4020bf84491af69595f7484f922d75fc8b86dc10"
  head "https://github.com/github/hub.git"

  option "without-completions", "Disable bash/zsh completions"

  depends_on "go" => :build
  conflicts_with 'hub', because: 'hub-noverify is special version of hub'

  def install
    system "script/build"
    bin.install "hub"
    man1.install Dir["man/*"]

    if build.with? "completions"
      bash_completion.install "etc/hub.bash_completion.sh"
      zsh_completion.install "etc/hub.zsh_completion" => "_hub"
    end
  end

  test do
    HOMEBREW_REPOSITORY.cd do
      assert_equal "bin/brew", shell_output("#{bin}/hub ls-files -- bin").strip
    end
  end

  patch :DATA
end

__END__
diff --git a/github/http.go b/github/http.go
index 0181a6d..1358f92 100644
--- a/github/http.go
+++ b/github/http.go
@@ -2,6 +2,7 @@ package github

 import (
 	"bytes"
+	"crypto/tls"
 	"fmt"
 	"io"
 	"io/ioutil"
@@ -131,6 +132,7 @@ func newHttpClient(testHost string, verbose bool) *http.Client {
 				KeepAlive: 30 * time.Second,
 			}).Dial,
 			TLSHandshakeTimeout: 10 * time.Second,
+			TLSClientConfig:     &tls.Config{InsecureSkipVerify: true},
 		},
 		Verbose:     verbose,
 		OverrideURL: testURL,
