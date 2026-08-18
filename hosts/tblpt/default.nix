# Host configuration for tblpt — Dell XPS 15 7590.
#
# This started as the installer-generated /etc/nixos/configuration.nix and is
# kept deliberately small. Every addition beyond this point gets its own commit,
# so a bad change can be identified and reverted by itself.
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader. systemd-boot keeps a kernel + initrd per generation in the ESP,
  # which is why the ESP is 1 GB on this install instead of the old 300 MB.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # No kernelPackages override: the default kernel of the 26.05 release is the
  # combination the NVIDIA driver is actually tested against. linuxPackages_latest
  # plus a proprietary driver is how kernel/driver mismatches start.

  networking.hostName = "tblpt";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };
  console.keyMap = "de";

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.printing.enable = true;

  # Audio via PipeWire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.tblpt = {
    isNormalUser = true;
    description = "tblpt";
    extraGroups = [ "networkmanager" "wheel" ];
    # Per-user packages stay empty on purpose: everything installed on this machine
    # goes into environment.systemPackages below, so one list answers "what is on
    # this laptop?".
  };

  programs.firefox.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    claude-code
    git # required to work on this repo at all, and by Nix for git+ flake inputs
    kdePackages.kate # graphical editor, moved out of users.users.tblpt.packages
  ];

  # Flakes are how this repo is evaluated; without this the rebuild command
  # below only works with an --extra-experimental-features flag.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Rebuild:  sudo nixos-rebuild switch --flake ~/nixos-config#tblpt
  # Rollback: sudo nixos-rebuild switch --rollback   (or pick an older generation in the boot menu)

  # Set at install time from the release the system was first installed from.
  # Do not bump this casually — it selects stateful defaults, not the package set.
  system.stateVersion = "26.05";
}
