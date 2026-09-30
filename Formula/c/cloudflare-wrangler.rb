class CloudflareWrangler < Formula
  desc "CLI tool for Cloudflare Workers"
  homepage "https://developers.cloudflare.com/workers/"
  url "https://registry.npmjs.org/wrangler/-/wrangler-4.143.1.tgz"
  sha256 "c8263c8d6a27d6d6b0eeadd9d5c13859396bd4f997666a26dba5ef2fcea78172"
  license any_of: ["Apache-2.0", "MIT"]

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "d135b37bce20abd49622dbb93fbad6ef84d5d57643545675cfc27c1081de715b"
    sha256 cellar: :any, arm64_tahoe:       "d135b37bce20abd49622dbb93fbad6ef84d5d57643545675cfc27c1081de715b"
    sha256 cellar: :any, arm64_sequoia:     "d135b37bce20abd49622dbb93fbad6ef84d5d57643545675cfc27c1081de715b"
    sha256 cellar: :any, arm64_linux:       "7c349a8d19f7f73358fc7b2fe9f1f805cce4d5f9cf45f9ec317ca2e00d519081"
    sha256 cellar: :any, x86_64_linux:      "474667499f2b6784eea02aa8f4f4e7de168fd1f73fbbd8f8db7dce6e88f339b5"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/wrangler*"]

    node_modules = libexec/"lib/node_modules/wrangler/node_modules"
    deuniversalize_machos node_modules/"fsevents/fsevents.node" if OS.mac?

    generate_completions_from_executable(bin/"wrangler", "complete", shells: [:bash, :zsh, :fish, :pwsh])
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/wrangler -v")
    assert_match "Required Worker name missing", shell_output("#{bin}/wrangler secret list 2>&1", 1)
  end
end
