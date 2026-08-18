{
  description = "NixOS configuration for tblpt (Dell XPS 15 7590)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Hardware quirks for this laptop. Wired in as a separate, later commit so a
    # broken NVIDIA/suspend change can be rolled back on its own.
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixos-hardware, ... }: {
    nixosConfigurations.tblpt = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/tblpt/default.nix
      ];
    };
  };
}
