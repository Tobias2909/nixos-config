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

  # Keep the ESP from filling up. The nixos-hardware module sets the equivalent
  # limit for GRUB, which this machine does not use.
  boot.loader.systemd-boot.configurationLimit = 10;

  # Newest kernel packaged in this release, currently 7.2.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # NVIDIA 610.57.04, the R610 feature branch. The 26.05 channel still ships
  # 595.71.05, so the version and hashes come from nixpkgs master and are built
  # against this system's own kernel rather than pulling master's package set in.
  # When 610 reaches the channel, this block can be deleted and the module's
  # default package used again.
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "610.57.04";
    sha256_64bit = "sha256-suk1xmuDuwDAyFe8jg7g/VLekoa0DJzB7sKafOfrEW0=";
    sha256_aarch64 = "sha256-QCefrMBCmpOwuOyXv1k5Gj0iB2CYlPgnG3JToUw/j54=";
    openSha256 = "sha256-rQHOOOY4KL92Ww3KDwh+j4eGU7oNAH8LutZC5wmFnPo=";
    settingsSha256 = "sha256-ZEMo8I8Zc2Tq6RVDNYpAH+f094dUaZiBqO+5f6lIjRI=";
    persistencedSha256 = "sha256-aXmD2VY1RLlgAnlHhOUMWzvMyhI6JTClcFLm4imF/mA=";
  };

  # Graphics come from nixos-hardware's dell-xps-15-7590-nvidia module, wired in
  # from flake.nix. It brings the proprietary NVIDIA driver with PRIME offload
  # (Intel drives the display, the GTX 1650 stays powered down until asked),
  # fine-grained NVIDIA power management, the open kernel modules for Turing,
  # mem_sleep_default=deep, thermald and fwupd.
  #
  # Run something on the dedicated GPU:  nvidia-offload <command>
  #
  # If a reboot after this lands on a black screen or nvidia-smi cannot talk to
  # the driver, boot the previous generation from the menu and try the closed
  # kernel modules instead of the open ones:
  #
  #   hardware.nvidia.open = lib.mkForce false;

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
