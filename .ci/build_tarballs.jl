# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

# Collection of sources required to build LCIOWrapBuilder
sources = [
    "https://github.com/jstrube/LCIOWrapBuilder.git" =>
    "451f42e9b3daf41156db502ee45ee8884b77efd2",
]

# Bash recipe for building across all platforms
function getscript(version)
	shortversion = version[1:3]
	return """
	Julia_ROOT=\$prefix
	cd \$WORKSPACE/srcdir
	mkdir build && cd build
	cmake -DCMAKE_INSTALL_PREFIX=\$prefix -DCMAKE_TOOLCHAIN_FILE=/opt/\$target/\$target.toolchain -DJulia_ROOT=\$Julia_ROOT ../LCIOWrapBuilder/
	VERBOSE=ON cmake --build . --config Release --target install
	"""
end

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = Platform[
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc7)),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc8)),
    # MacOS(:x86_64, compiler_abi=CompilerABI(:gcc7)),
    # MacOS(:x86_64, compiler_abi=CompilerABI(:gcc8)),
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "liblciowrap", :lciowrap)
]

# Dependencies that must be installed before this package can be built
dependencies = [
	"https://github.com/JuliaInterop/libcxxwrap-julia/releases/download/v0.5.0/build_libcxxwrap-julia-1.0.v0.5.0.jl"
	"https://github.com/jstrube/LCIOBuilder/releases/download/v2.12.2/build_LCIOBuilder.v2.12.1.jl"
	"https://github.com/JuliaPackaging/JuliaBuilder/releases/download/v1.0.0-2/build_Julia.v1.0.0.jl"
]

# Build the tarballs, and possibly a `build.jl` as well.
version_number = get(ENV, "TRAVIS_TAG", "")
if version_number == ""
    version_number = "v0.99"
end
build_tarballs(ARGS, "LCIOWrapBuilder-1.0", VersionNumber(version_number), sources, getscript("1.0.0"), platforms, products, dependencies)

