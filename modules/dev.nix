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
  ];
}
