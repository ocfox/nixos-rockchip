{
  description = "Build NixOS images for rockchip based single computer boards";

  inputs = {
    rockchip.url = "github:nabam/nixos-rockchip";
    utils.url    = "github:numtide/flake-utils";
    nixpkgs.url  = "github:NixOS/nixpkgs/nixos-22.11";
  };

  outputs = { self, ... }@inputs:
    let
      pkgs = import inputs.nixpkgs {
        system = "aarch64-linux";
        config = { allowUnfree = true; };
      };
      osConfig = inputs.nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          inputs.rockchip.nixosModules.sd-image-rockchip
          ( inputs.nixpkgs + "/nixos/modules/installer/cd-dvd/channel.nix" )
          ./config.nix
          { 
            rockchip.uBoot = inputs.rockchip.uBoot.uBootQuartz64A; 
            boot.kernelPackages = inputs.rockchip.kernel.linux_6_1; 
          }
        ];
        specialArgs = {
          inherit inputs;
        };
      };
    in inputs.utils.lib.eachDefaultSystem (system: {
      packages.image = osConfig.config.system.build.sdImage;
      defaultPackage = self.packages."${system}".image;
    });
}
