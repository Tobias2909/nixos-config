# Desktop applications and the bits of the desktop that are not Plasma itself.
#
# Plasma 6, SDDM, PipeWire and printing live in hosts/tblpt/default.nix because
# they came with the install.
{ pkgs, ... }:

{
  # The pressure-release valve for anything not packaged in nixpkgs. The old
  # system already ran seven Flatpaks, so this is a familiar pattern.
  services.flatpak.enable = true;

  environment.systemPackages = with pkgs; [
    # Browsers. Firefox comes from programs.firefox in the host config.
    chromium
    floorp-bin # `floorp` was renamed: 12.x cannot be built from source

    # Media
    vlc
    gimp

    # Chat
    discord
    teams-for-linux

    # System tools
    gparted
    gnome-disk-utility
    mission-center

    gammastep # night colour shift
    nordzy-icon-theme # the icon theme cloned by hand on the old system
  ];
}
