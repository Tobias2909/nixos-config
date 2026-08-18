# Development tooling.
#
# Language toolchains are deliberately thin here. For anything project-specific,
# a per-project flake devShell is the better answer than installing SDKs system
# wide — that is the habit worth building on this OS.
{ pkgs, ... }:

{
  # Docker Desktop is not packaged and is not needed; the daemon plus the CLI
  # covers everything the lab work used it for.
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    docker-compose
    vscode
    python3
    jdk # currently 21

    # JetBrains IDEs from nixpkgs rather than the Toolbox App: Toolbox needs an
    # FHS environment and updates itself outside Nix, which is what made it 38 GB
    # of ~/.local on the old system. Note the paid editions were merged upstream:
    # idea-ultimate is now `idea`, pycharm-professional is now `pycharm`. Sign in
    # with your student licence as before.
    jetbrains.idea
    jetbrains.rider
    jetbrains.clion
    jetbrains.pycharm
  ];
}
