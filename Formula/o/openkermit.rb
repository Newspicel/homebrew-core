class Openkermit < Formula
  desc "Scriptable network and serial communication for UNIX and VMS"
  homepage "https://www.openkermit.org/"
  url "https://github.com/openkermit/ckermit/archive/refs/tags/v11.0.513.tar.gz"
  sha256 "b59c38328e087063496b1ac61df1d9d9d912e2532be59a67868ac9ed53e10717"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_golden_gate: "66bf47881feadfe5c6497326c1ea6a96a07bd65edd68a8f7f2fe5306f3a92fa0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:       "f37c099016bc6e4ec3c24ea184fa94af3de3e558af8cf34fb2a0a7f5a785c03d"
    sha256 cellar: :any_skip_relocation, arm64_sequoia:     "396dc4ef6f4d73d520b954f393d785f1918125bb8cd769fb4cb63f969d93028b"
    sha256 cellar: :any,                 arm64_linux:       "e01bc780619db21056800def7bb6392c26c2aa9b5fe1a5d2dc4be6533f507f0b"
    sha256 cellar: :any,                 x86_64_linux:      "cca8b33cc400833480f3c1cfd778d8553c40de7efb55e7dad196335d75c02521"
  end

  uses_from_macos "libxcrypt"
  uses_from_macos "ncurses"

  def install
    os = OS.mac? ? "macosx" : "linux"
    system "make", os, "KFLAGS=-DCK_NCURSES -I#{formula_opt_include("ncurses")}"

    man1.mkpath

    # The makefile adds /man to the end of manroot when running install
    # hence we pass share here, not man.  If we don't pass anything it
    # uses {prefix}/man
    system "make", "prefix=#{prefix}", "manroot=#{share}", "install"
  end

  test do
    # /confirm:off keeps this headless.
    system "#{bin}/kermit", "-C",
           "set host /network-type:pseudoterminal \"kermit -x\", get /confirm:off /bin/sh, bye, quit"
    assert_path_exists "sh"
  end
end
