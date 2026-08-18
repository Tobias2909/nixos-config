{
  description = "NixOS configuration for tblpt (Dell XPS 15 7590)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Hardware quirks for this laptop: deep sleep, thermald, fwupd, SSD trim and
    # the hybrid Intel/NVIDIA graphics setup.
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # $HOME state: dotfiles and, through plasma-manager, the Plasma desktop
    # itself. Both follow this flake's nixpkgs so there is only one package set.
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      plasma-manager,
      ...
    }:
    {
      nixosConfigurations.tblpt = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          # Verified against this machine: the module's default PRIME bus IDs
          # (Intel PCI:0:2:0, NVIDIA PCI:1:0:0) are the real addresses here.
          nixos-hardware.nixosModules.dell-xps-15-7590-nvidia

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-bak"; # so activation never loses an existing dotfile
              sharedModules = [ plasma-manager.homeManagerModules.plasma-manager ];
              users.tblpt = import ./home/tblpt.nix;
            };
          }

          ./hosts/tblpt/default.nix
        ];
      };
    };
}
