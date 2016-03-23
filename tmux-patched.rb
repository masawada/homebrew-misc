class TmuxPatched < Formula
  desc "Terminal multiplexer"
  homepage "https://tmux.github.io/"

  conflicts_with 'tmux', because: 'tmux-patched is special version of tmux'

  stable do
    url "https://github.com/tmux/tmux/releases/download/2.1/tmux-2.1.tar.gz"
    sha256 "31564e7bf4bcef2defb3cb34b9e596bd43a3937cad9e5438701a81a5a9af6176"

    patch do
      # This fixes the Tmux 2.1 update that broke the ability to use select-pane [-LDUR]
      # to switch panes when in a maximized pane https://github.com/tmux/tmux/issues/150#issuecomment-149466158
      url "https://github.com/tmux/tmux/commit/a05c27a7e1c4d43709817d6746a510f16c960b4b.diff"
      sha256 "2a60a63f0477f2e3056d9f76207d4ed905de8a9ce0645de6c29cf3f445bace12"
    end

    patch do
      # This fixes the Tmux 2.1 update that breaks "tmux killw\; detach"
      # https://github.com/tmux/tmux/issues/153#issuecomment-150184957
      url "https://github.com/tmux/tmux/commit/3ebcf25149d75977ea97e9d4f786e0508d1a0d5e.diff"
      sha256 "65a8bc0b2f6a8b41ad27605fd99419fff36314499969adc9d17dd3940a173508"
    end
  end

  head do
    url "https://github.com/tmux/tmux.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "pkg-config" => :build
  depends_on "libevent"

  def patches
    [
      "https://gist.githubusercontent.com/waltarix/1399751/raw/8c5f0018c901f151d39680ef85de6d22649b687a/tmux-ambiguous-width-cjk.patch",
      "https://gist.githubusercontent.com/waltarix/1399751/raw/dc11f40266d9371e730eff41c64a70c84d34484a/tmux-pane-border-ascii.patch",
    ]
  end

  def install
    system "sh", "autogen.sh" if build.head?

    ENV.append "LDFLAGS", "-lresolv"
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--sysconfdir=#{etc}"

    system "make", "install"

    if build.head?
      pkgshare.install "example_tmux.conf"
    else
      bash_completion.install "examples/bash_completion_tmux.sh" => "tmux"
      pkgshare.install "examples"
    end
  end

  def caveats; <<-EOS.undent
    Example configuration has been installed to:
      #{opt_pkgshare}
    EOS
  end

  test do
    system "#{bin}/tmux", "-V"
  end
end
