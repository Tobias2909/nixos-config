# Everything the university work depends on.
#
# These are the four things the migration is measured by: campus WiFi, VPN, SSH
# to the lab hosts, and being able to compile a lab report.
{ pkgs, ... }:

{
  # eduVPN needs the NetworkManager OpenVPN plugin present, otherwise it fails
  # with "Expected one openvpn VPN plugins, got: 0" (nixpkgs issue #424326).
  networking.networkmanager.plugins = with pkgs; [
    networkmanager-openvpn
  ];

  environment.systemPackages = with pkgs; [
    # Campus WiFi. Logging in issues a fresh client certificate and writes an
    # ordinary NetworkManager EAP-TLS connection — see docs/HANDOVER.md §2.
    easyroam-connect-desktop

    eduvpn-client

    # Lab reports. scheme-medium rather than full: full is tens of GB and the
    # reports so far have not needed it.
    texstudio
    texliveMedium

    keepassxc # database lives on the desktop PC, copy it over
    thunderbird
    onedriver # OneDrive mount, used to sit at ~/Desktop/OneDriver
  ];
}
