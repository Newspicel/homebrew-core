class AwsCrtCpp < Formula
  desc "C++ wrapper around the aws-c-* libraries"
  homepage "https://github.com/awslabs/aws-crt-cpp"
  url "https://github.com/awslabs/aws-crt-cpp/archive/refs/tags/v0.43.7.tar.gz"
  sha256 "25c3d10b86627540d1aa0c24f45d730cf4b46414f24d60b6877795b2980be80d"
  license "Apache-2.0"
  revision 2
  compatibility_version 1

  bottle do
    sha256 cellar: :any, arm64_golden_gate: "8b1a322c8c418a96db6b0622798b375eaefc18ca5cb4e7463543c625af952581"
    sha256 cellar: :any, arm64_tahoe:       "ce1bb380dd8459dc350d7d3dc600be2d53cd45c1b7d973cc846c4cd64921e625"
    sha256 cellar: :any, arm64_sequoia:     "4e6861bf82ba49c9ff832f58055bf7e3f50fabd66d1253f3f203c1dbaac7d8b2"
    sha256 cellar: :any, arm64_linux:       "94587ef3cdb239b9f02f52e04e7589d2b77dc1c2ce63b2d28abf364b0665cb78"
    sha256 cellar: :any, x86_64_linux:      "4082175fc1d0f19d74f8c3923291da15845b28f440eda39128c9bc32cf9d66e6"
  end

  depends_on "cmake" => :build
  depends_on "aws-c-auth"
  depends_on "aws-c-cal"
  depends_on "aws-c-common"
  depends_on "aws-c-event-stream"
  depends_on "aws-c-http"
  depends_on "aws-c-io"
  depends_on "aws-c-mqtt"
  depends_on "aws-c-s3"
  depends_on "aws-c-sdkutils"
  depends_on "aws-checksums"

  deny_network_access!

  def install
    args = %W[
      -DBUILD_DEPS=OFF
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_MODULE_PATH=#{formula_opt_lib("aws-c-common")}/cmake
    ]
    # Avoid linkage to `aws-c-compression`
    args << "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-dead_strip_dylibs" if OS.mac?

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <aws/crt/Allocator.h>
      #include <aws/crt/Api.h>
      #include <aws/crt/Types.h>
      #include <aws/crt/checksum/CRC.h>

      int main() {
        Aws::Crt::ApiHandle apiHandle(Aws::Crt::DefaultAllocatorImplementation());
        uint8_t data[32] = {0};
        Aws::Crt::ByteCursor dataCur = Aws::Crt::ByteCursorFromArray(data, sizeof(data));
        assert(0x190A55AD == Aws::Crt::Checksum::ComputeCRC32(dataCur));
        return 0;
      }
    CPP
    system ENV.cxx, "-std=c++11", "test.cpp", "-o", "test", "-L#{lib}", "-laws-crt-cpp"
    system "./test"
  end
end
