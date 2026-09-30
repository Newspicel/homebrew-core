class PiCodingAgent < Formula
  desc "AI agent toolkit"
  homepage "https://pi.dev/"
  url "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-0.99.0.tgz"
  sha256 "19a8dbd8d697a599ea972a8ba307c109a814bb9122604b2553c62006b9617724"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "2638593ecfc0b4c88a794b8f0b8b7cfd069adbce70617ec7ffbd58d00a14e56e"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "2638593ecfc0b4c88a794b8f0b8b7cfd069adbce70617ec7ffbd58d00a14e56e"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "2638593ecfc0b4c88a794b8f0b8b7cfd069adbce70617ec7ffbd58d00a14e56e"
    sha256 cellar: :any,                 arm64_linux:       "f40e8d034fc63ff479428a62cf78e87fd375146419a8334f6efdbd33b1945ff2"
    sha256 cellar: :any,                 x86_64_linux:      "1c0d77d992f1f55969e61c6218b7545c6a24bb0286ba4847a051dbdb22d01ab8"
  end

  depends_on "node"

  on_linux do
    depends_on "libxcb"
  end

  def install
    system "npm", "install", *std_npm_args
    (bin/"pi").write_env_script libexec/"bin/pi", PI_SKIP_VERSION_CHECK: "1"

    node_modules = libexec/"lib/node_modules/@earendil-works/pi-coding-agent/node_modules/"
    arch = Hardware::CPU.arm? ? "arm64" : "x64"
    os = OS.linux? ? "linux" : "darwin"
    node_modules.glob("@earendil-works/pi-tui/native/**/prebuilds/*").each do |dir|
      basename = dir.basename.to_s
      rm_r(dir) if basename != "#{os}-#{arch}"
    end

    # Rebuild the X11 clipboard helper against our `libxcb`
    system "bash", node_modules/"@earendil-works/pi-tui/native/linux/build.sh" if OS.linux?
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pi --version 2>&1")

    ENV["GEMINI_API_KEY"] = "invalid_key"
    output = shell_output("#{bin}/pi -p 'foobar' 2>&1", 1)
    assert_match "API key not valid", output
  end
end
