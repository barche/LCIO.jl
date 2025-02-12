using BinaryProvider
using CxxWrap # this is needed for opening the dependency lib. Otherwise Libdl.dlopen fails

##################### LCIO ###########################
# We are trying to find the right version of LCIO. By default, don't set anything and the right version will just be downloaded. However, for debugging purposes, we'd might want to use the pre-installed lib
const lcioversion = "02-12-01"
const LCIO_DIR = get(ENV, "LCIO_DIR", "")
const verbose = "--verbose" in ARGS
const lcioprefix = Prefix(LCIO_DIR == "" ? get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")) : LCIO_DIR)

# The products that we will ensure are always built
lcioproducts = [
    LibraryProduct(lcioprefix, "liblcio", :liblcio),
    LibraryProduct(lcioprefix, "libsio", :libsio)
]
# Download binaries from hosted location
bin_prefix = "https://github.com/jstrube/LCIOBuilder/releases/download/v2.12.1-4"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/LCIOBuilder.v2.12.1-4.x86_64-apple-darwin14-gcc7.tar.gz", "61be2eb8f7cd6345849781b65974cce76f8427a1f2b7e989480171604ca1dd70"),
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/LCIOBuilder.v2.12.1-4.x86_64-apple-darwin14-gcc8.tar.gz", "25bddf754aae66bcc09b549af7446abfd559fe6b5b994cca63faf463352818b1"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/LCIOBuilder.v2.12.1-4.x86_64-linux-gnu-gcc4.tar.gz", "1d541f3525ace53609df042599f715a01c7985ca8e0a97ccff108a02119b91f2"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/LCIOBuilder.v2.12.1-4.x86_64-linux-gnu-gcc7.tar.gz", "dd91bee706b76f9ea92a33366614ffc01250c233675e9a2df9280c7d72ed3f29"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc7, :cxx11)) => ("$bin_prefix/LCIOBuilder.v2.12.1-4.x86_64-linux-gnu-gcc7-cxx11.tar.gz", "c2c28c4456a74f14cc3d545b61ed88a9f41ac002716983ce2c4a24a84c36327f"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/LCIOBuilder.v2.12.1-4.x86_64-linux-gnu-gcc8.tar.gz", "4032161089689a3c87cd191c17d84f975d70960399c539546d9a4be3b6c1a747"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc8, :cxx11)) => ("$bin_prefix/LCIOBuilder.v2.12.1-4.x86_64-linux-gnu-gcc8-cxx11.tar.gz", "f4dde09b0975e4c4f280e4be08354356232e0b892f9d3ec56c22bbf6b645f986"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in lcioproducts)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=lcioprefix)
    # Download and install binaries
    install(dl_info...; prefix=lcioprefix, force=true, verbose=verbose)
end
######################################################

################### LCIO Wrapper #####################
const wrapprefix = Prefix(joinpath(@__DIR__, "usr"))

# Download binaries from hosted location
bin_prefix = "https://github.com/jstrube/LCIOWrapBuilder/releases/download/v0.5.1"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/LCIOWrapBuilder-1.0.v0.5.1.x86_64-apple-darwin14-gcc7.tar.gz", "c0e5f898c7a6158a9053fa26365d6e9fba25c63453b50e7c00058116b9a0815e"),
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/LCIOWrapBuilder-1.0.v0.5.1.x86_64-apple-darwin14-gcc8.tar.gz", "58f516ef45ac9313e2ba3da0af609e146db53e03f8257c783559e886a5fbd321"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc7, :cxx11)) => ("$bin_prefix/LCIOWrapBuilder-1.0.v0.5.1.x86_64-linux-gnu-gcc7-cxx11.tar.gz", "0ce4d5993fed8b6c6193b47afeaa82531bfc5555516ba4570accd4ef95a0c47a"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc8, :cxx11)) => ("$bin_prefix/LCIOWrapBuilder-1.0.v0.5.1.x86_64-linux-gnu-gcc8-cxx11.tar.gz", "aeeccca138f10b572063de18b65126f6744da72f5ea55adf7b91f8408bc4d7d7"),
)

# The products that we will ensure are always built
wrapproducts = [
    LibraryProduct(wrapprefix, "liblciowrap", :liblciowrap)
]

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in wrapproducts)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=wrapprefix)
    # Download and install binaries
    install(dl_info...; prefix=wrapprefix, force=true, verbose=verbose) 
end

write_deps_file(joinpath(@__DIR__, "deps.jl"), [lcioproducts; wrapproducts])
