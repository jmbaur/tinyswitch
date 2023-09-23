# SOC := rtl8380
# IMAGE_SIZE := 6976k
# DEVICE_VENDOR := Zyxel
# DEVICE_MODEL := GS1900-10HP
{ openwrt
, bc
, bison
, buildPackages
, cpio
, elfutils
, flex
, gmp
, kmod
, lib
, libmpc
, linuxKernel
, mpfr
, nettools
, openssl
, pahole
, perl
, python3Minimal
, rsync
, stdenv
, ubootTools
, zlib
, zstd
}:
stdenv.mkDerivation rec {
  inherit (linuxKernel.kernels.linux_5_15)
    pname
    version
    src
    makeFlags
    preInstall
    enableParallelBuilding;

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  nativeBuildInputs = [ ubootTools perl bc nettools openssl rsync gmp libmpc mpfr zstd python3Minimal ]
    ++ lib.optionals (lib.versionAtLeast version "4.16") [ bison flex ]
    ++ lib.optionals (lib.versionAtLeast version "5.2") [ cpio pahole zlib ]
    ++ lib.optional (lib.versionAtLeast version "5.8") elfutils
    ++ lib.optional (lib.versionAtLeast version "6.6") kmod;

  configfile = "${openwrt}/target/linux/realtek/rtl838x/config-5.15";

  configurePhase = ''
    runHook preConfigure
    cp --no-preserve=all $configfile .config
    make ARCH=${stdenv.hostPlatform.linuxArch} olddefconfig
    runHook postConfigure
  '';

  postPatch = ''
    cp -r ${openwrt}/target/linux/realtek/files/firmware .
  '';

  buildFlags = [ "DTC_FLAGS=-@" "KBUILD_BUILD_VERSION=1-TinySwitch" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp arch/mips/boot/vmlinux.gz.itb $out

    runHook postInstall
  '';
}
