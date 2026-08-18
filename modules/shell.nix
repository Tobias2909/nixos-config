# zsh, rebuilt declaratively.
#
# The old system cloned oh-my-zsh, powerlevel10k and two plugins by hand into
# $HOME. All four are NixOS options or packages, so none of that is needed here.
{ pkgs, ... }:

{
  programs.zsh = {
    enable = true; # required, or a zsh login shell is broken

    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    ohMyZsh = {
      enable = true;
      plugins = [
        "git"
        "fzf"
        "extract"
      ];
    };

    # powerlevel10k as the prompt. The generated ~/.p10k.zsh from the old system
    # is sourced below if present; run `p10k configure` to regenerate it.
    promptInit = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
    '';

    interactiveShellInit = ''
      source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down

      fastfetch
    '';

    shellAliases = {
      c = "clear";
      please = "sudo";
      jctl = "journalctl -p 3 -xb";
      tb = "nc termbin.com 9999";

      # The apt versions of these two, translated.
      update = "sudo nixos-rebuild switch --flake ~/nixos-config#tblpt";
      cleanup = "sudo nix-collect-garbage -d";
    };
  };

  environment.systemPackages = with pkgs; [
    zsh-powerlevel10k
    zsh-history-substring-search

    fastfetch
    btop
    fzf
    tealdeer # the `tldr` command
    tree
    unzip
    wget
    nettools # the `net-tools` suite: ifconfig, netstat, route
    speedtest-cli
  ];
}
