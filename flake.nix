{
  description = "tinyswitch";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    openwrt = {
      url = "git+https://git.openwrt.org/openwrt/openwrt.git";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, openwrt }:
    let
      forEachSystem = f: nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" ] (system: f {
        inherit system;
        pkgs = import nixpkgs { inherit system; };
      });
    in

    {
      packages = forEachSystem ({ pkgs, ... }: {
        gs1900-10hp-kernel = pkgs.pkgsCross.mips-linux-gnu.callPackage ./gs1900-10hp-kernel.nix { inherit openwrt; };
      });
    };
}
