#!/usr/bin/env bash
# Snapshot the current KDE Plasma settings into the repo.
#
# Writes home/plasma-generated.nix, which home/tblpt.nix imports. Run it after
# changing something in System Settings that you want to survive a reinstall,
# then commit the result.
#
# Note what this does and does not capture:
#   - it captures shortcuts, and the contents of KDE's rc files
#   - it does NOT capture the panel or its widgets; those are declared by hand in
#     home/tblpt.nix, because rc2nix cannot read the applet layout
#   - it captures defaults and application session state as well as your own
#     choices, so the diff will be noisy
set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="$repo/home/plasma-generated.nix"

echo "running rc2nix..."
nix run github:nix-community/plasma-manager#rc2nix > "$out.tmp"

# rc2nix emits a full module: { programs.plasma = { enable = true; ... }; }
# `enable` and the panel list stay owned by home/tblpt.nix, so drop them here to
# avoid defining the same option in two files.
sed -e '/^    enable = true;$/d' "$out.tmp" > "$out"
rm -f "$out.tmp"

echo "wrote $out"
echo
echo "next:"
echo "  git -C $repo add home/plasma-generated.nix"
echo "  git -C $repo diff --cached home/plasma-generated.nix   # what changed"
echo "  sudo nixos-rebuild switch --flake $repo#tblpt"
