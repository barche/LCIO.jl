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
bin_prefix = "https://github.com/jstrube/LCIOBuilder/releases/download/v2.12.2"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/LCIOBuilder.v2.12.1.x86_64-apple-darwin14-gcc7.tar.gz", "4c21a0e0682d1c0f9da84b1065329bd80276883c5605ad50f05cde09267500c3"),
    MacOS(:x86_64, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/LCIOBuilder.v2.12.1.x86_64-apple-darwin14-gcc8.tar.gz", "adfbca242dd9d91aa66273b341b48b34bc9370864c109f062bad46557efcb9a3"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc4)) => ("$bin_prefix/LCIOBuilder.v2.12.1.x86_64-linux-gnu-gcc4.tar.gz", "5b22f123e1c8217e18b4fc8f75a5ce1402f0dd935c47cc74e7787d0d9e422ff7"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/LCIOBuilder.v2.12.1.x86_64-linux-gnu-gcc7.tar.gz", "835e3ee7d40ada0a3e9c553e2c4828d0947867f60d4f71bced71bb756fc73cee"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/LCIOBuilder.v2.12.1.x86_64-linux-gnu-gcc8.tar.gz", "38bed76b9de6a7b1ead859c39659bf787462ea1f6cfb7f28798fb39795c35dda"),
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
bin_prefix = "https://github.com/jstrube/LCIOWrapBuilder/releases/download/v0.5-pre"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/LCIOWrapBuilder-1.0.v0.5.0-pre.x86_64-linux-gnu-gcc7.tar.gz", "78ae9b4a763e66636c81f2b19c4bb384dfc3a75c1e23f074ba232f15fbecb606"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/LCIOWrapBuilder-1.0.v0.5.0-pre.x86_64-linux-gnu-gcc8.tar.gz", "68793ab0f61f59b340b02fde897e32402bb6bf779e254f59a144b131eee35ae4"),
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
