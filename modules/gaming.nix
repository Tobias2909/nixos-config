# Games. Easy to comment out of the host's import list.
{ ... }:

{
  # The option rather than the package: it pulls in the 32-bit graphics driver
  # stack, opens the Remote Play and Steam Link firewall ports, and keeps the
  # udev rules for controllers in one place.
  programs.steam.enable = true;
}
