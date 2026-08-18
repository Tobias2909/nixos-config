{
  description = "NixOS configuration for tblpt (Dell XPS 15 7590)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Hardware quirks for this laptop: deep sleep, thermald, fwupd, SSD trim and
    # the hybrid Intel/NVIDIA graphics setup.
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixos-hardware, ... }: {
    nixosConfigurations.tblpt = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Verified against this machine: the module's default PRIME bus IDs
        # (Intel PCI:0:2:0, NVIDIA PCI:1:0:0) are the real addresses here.
        nixos-hardware.nixosModules.dell-xps-15-7590-nvidia
        ./hosts/tblpt/default.nix
      ];
    };
  };
}
