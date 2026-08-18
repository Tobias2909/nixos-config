# Per-user configuration for tblpt, via home-manager.
#
# Everything here is $HOME state that the system config cannot reach: the Plasma
# panel, KDE settings, and dotfiles. Without this the repo rebuilds the machine
# but leaves a default desktop behind.
#
# To capture GUI changes made after this file was written:
#   nix run github:nix-community/plasma-manager#rc2nix
# It prints the current KDE settings as Nix. Note two limits: it dumps defaults
# as well as your changes, and it does not capture the panel — panels are
# declared explicitly below.
{ ... }:

{
  home.stateVersion = "26.05";

  home.file.".p10k.zsh".source = ../dotfiles/p10k.zsh;

  programs.plasma = {
    enable = true;

    workspace.lookAndFeel = "org.kde.breezedark.desktop";

    panels = [
      {
        location = "bottom";
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          "org.kde.plasma.icontasks"

          # Four system monitors, in the order they sit on the panel.
          {
            systemMonitor = {
              title = "CPU";
              displayStyle = "org.kde.ksysguard.facegrid";
              sensors = map (n: {
                name = "cpu/cpu${toString n}/usage";
                label = "CPU ${toString n}";
                color = "170,0,255";
              }) (builtins.genList (x: x) 12);
            };
          }
          {
            systemMonitor = {
              title = "GPU";
              displayStyle = "org.kde.ksysguard.linechart";
              sensors = [
                {
                  name = "gpu/gpu0/usage";
                  label = "GPU";
                  color = "0,85,255";
                }
              ];
            };
          }
          {
            systemMonitor = {
              title = "RAM_VRAM";
              displayStyle = "org.kde.ksysguard.horizontalbars";
              sensors = [
                {
                  name = "memory/physical/used";
                  label = "RAM";
                  color = "170,0,255";
                }
                {
                  name = "gpu/gpu0/totalVram";
                  label = "VRAM";
                  color = "255,0,0";
                }
              ];
            };
          }
          {
            systemMonitor = {
              title = "WLAN";
              displayStyle = "org.kde.ksysguard.facegrid";
              sensors = [
                {
                  name = "network/all/download";
                  label = "Download";
                  color = "0,85,255";
                }
                {
                  name = "network/all/upload";
                  label = "Upload";
                  color = "85,170,0";
                }
              ];
            };
          }

          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemtray"
          "org.kde.plasma.digitalclock"
          "org.kde.plasma.showdesktop"
        ];
      }
    ];
  };
}
