# Software inventory — tblpt, captured 2026-08-18

## Ground rule: nothing here gets installed by default

**This is a record of what the old system had, not a plan for the new one.**

Explicit decision, 2026-08-18: the new system starts near-empty and every single
package is chosen individually. The value of this file is *"did I forget
something?"*, not *"install all of this"*. It exists so that when something is
missing three weeks from now, the answer is one lookup away instead of a
half-remembered guess.

How to use it:

- Do **not** work top-to-bottom through this file.
- Install a package the first time you actually reach for it and it is not there.
- One package per commit, rebuild after each. When something breaks you know
  exactly what broke it.
- Most of this list should still be uninstalled in six months. That is the
  intended outcome, not a sign of an incomplete migration.

The `Verdict` notes below are about *how* to install something on NixOS **if** you
decide you want it — never a recommendation that you should.

Legend for the "On NixOS" column:
`nixpkgs` = just add to `environment.systemPackages`
`option` = has a proper NixOS option, use that instead of the bare package
`flatpak` = install via Flatpak
`?` = needs checking / no clean route known

---

## Uni-critical — do these first

| Software | Current source | On NixOS | Note |
|---|---|---|---|
| easyroam | flatpak `de.easyroam.easyroam` | `nixpkgs` (`easyroam-connect-desktop`) / flatpak / `nix-easyroam` module | See HANDOVER §2 |
| eduVPN | apt `eduvpn-client` (vendor repo) | `nixpkgs` (`eduvpn-client`) | needs `networkmanager.plugins = [ networkmanager-openvpn ]` |
| OpenSSH client + keys | base | `option` (`programs.ssh`) | restore `~/.ssh/` |
| onedriver (OneDrive mount) | apt | `nixpkgs` (`onedriver`) | mounted at `~/Desktop/OneDriver`, ~60 GB cloud-side |
| TeXStudio + TeX Live | apt (4 texlive pkgs) | `nixpkgs` (`texstudio`, `texlive.combined.scheme-medium`) | scheme-full is huge; medium usually enough |
| KeePassXC | apt `keepassxc-full` | `nixpkgs` (`keepassxc`) | DB at `~/Documents/Database.kdbx` |
| Thunderbird | snap | `option` (`programs.thunderbird`) or nixpkgs | |
| Portal for Teams | flatpak `com.github.IsmaelMartinez.teams_for_linux` | `flatpak` or `nixpkgs` (`teams-for-linux`) | |

## Desktop / KDE base

| Software | Current | On NixOS |
|---|---|---|
| KDE Plasma 6 + SDDM | apt `kubuntu-desktop` | `option` `services.desktopManager.plasma6.enable` |
| Dolphin, Konsole, Kate, Okular, Gwenview, Ark, Spectacle, KHelpCenter | part of Plasma | come with plasma6 / `kdePackages.*` |
| Haruna (video) | apt | `nixpkgs` (`kdePackages.haruna`) |
| VLC | apt | `nixpkgs` (`vlc`) |
| Gammastep (night colour) | apt/config present | `nixpkgs` (`gammastep`) |
| Breeze-Chameleon Light icons / Nordzy-icon | manual git clone in `~/Nordzy-icon` | `nixpkgs` (`nordzy-icon-theme`) — check name |
| GNOME Disks, GParted, baobab | apt | `nixpkgs` (`gnome-disk-utility`, `gparted`, `baobab`) |
| Seahorse + gnome-keyring | apt | `option` `services.gnome.gnome-keyring.enable` |
| Mission Center | flatpak | `flatpak` or `nixpkgs` (`mission-center`) |
| Flatpak itself | apt | `option` `services.flatpak.enable = true` |

## Browsers

| Software | Current | On NixOS |
|---|---|---|
| Firefox | snap | `option` `programs.firefox` |
| Chromium | snap | `nixpkgs` (`chromium`) |
| Zen Browser | flatpak `app.zen_browser.zen` | `flatpak` (cleanest) |

Also present but only as leftover Flatpak data dirs (not installed): Chrome,
Chrome Dev, ungoogled-chromium, LibreWolf, Waterfox. Don't bother reinstalling.

## Development

| Software | Current | On NixOS | Note |
|---|---|---|---|
| Docker + compose + buildx | apt `docker-ce` | `option` `virtualisation.docker.enable` | add user to `docker` group |
| **Docker Desktop** | apt `docker-desktop`, `/opt/docker-desktop` | **drop it** | not packaged; plain docker CLI covers everything you do |
| VS Code | snap `code` | `nixpkgs` (`vscode`) | extensions in `raw/vscode-extensions.txt` |
| JetBrains: IntelliJ Ultimate, Rider, CLion, PyCharm | Toolbox App (`~/.local/share/JetBrains/Toolbox`) | `nixpkgs` `jetbrains.{idea-ultimate,rider,clion,pycharm-professional}` | **use nixpkgs, not Toolbox** — Toolbox needs FHS and updates itself outside Nix. 38 GB of `~/.local` is this. |
| .NET 9 SDK + runtimes + ASP.NET | apt (MS repo) | `nixpkgs` (`dotnetCorePackages.sdk_9_0`) | |
| Java (default-jre) + JDKs | apt + `~/.jdks` | `nixpkgs` (`jdk`, `temurin-bin-*`) | |
| Python 3 + pip | apt | `nixpkgs` (`python3`) | use `uv`/venv or nix shells, **not** `pip install --user` |
| gcc, cmake, meson, ninja | apt | `nixpkgs` | better: per-project `devShell` in a flake |
| Git | apt | `option` `programs.git` | |
| Godot | apt | `nixpkgs` (`godot`) | |
| VirtualBox + `Win11` VM | apt `virtualbox-qt` | `option` `virtualisation.virtualbox.host.enable` | 58 GB. **Export to .ova before wiping.** Consider virt-manager/QEMU instead — better supported on NixOS. |
| Claude Code | `~/.local/bin/claude` | `nixpkgs` (`claude-code`) or official installer | |
| GitHub Copilot / Junie configs | `~/.copilot`, `~/.junie` | just config, copy if wanted | |

## Shell / CLI

| Software | Current | On NixOS |
|---|---|---|
| zsh | apt | `option` `programs.zsh.enable` (required for the login shell to work) |
| oh-my-zsh | manual clone `~/.oh-my-zsh` | `option` `programs.zsh.ohMyZsh` |
| powerlevel10k | manual clone `~/powerlevel10k` | `nixpkgs` (`zsh-powerlevel10k`) |
| zsh-autosuggestions, zsh-syntax-highlighting | apt | `option` `programs.zsh.autosuggestions` / `syntaxHighlighting` |
| zsh-history-substring-search | manual clone `~/.zsh/` | `nixpkgs` (`zsh-history-substring-search`) |
| fastfetch | apt | `nixpkgs` (`fastfetch`) |
| btop, fzf, net-tools, speedtest-cli, tldr | apt | `nixpkgs` (`btop`, `fzf`, `nettools`, `speedtest-cli`, `tealdeer`) |
| msmtp (+ `.msmtprc`) | apt | `nixpkgs` (`msmtp`) — **config has a password, keep out of git** |
| GnuPG | apt | `option` `programs.gnupg.agent` |
| efibootmgr, mokutil, wimtools, hardinfo2 | apt | `nixpkgs` — install if actually needed |
| fs tools: btrfs-progs, lvm2, xfsprogs, jfsutils, reiserfsprogs | apt (pulled by Calamares) | skip unless needed |

## Media / social / games

| Software | Current | On NixOS |
|---|---|---|
| Discord | snap | `nixpkgs` (`discord`) |
| ZapZap (WhatsApp) | flatpak, autostarts | `flatpak` or `nixpkgs` (`zapzap`) |
| Notion | snap `notion-snap-reborn` | `flatpak` / web app |
| YouTube Music Desktop | snap | `flatpak` or `nixpkgs` (`youtube-music`) |
| GIMP | apt | `nixpkgs` (`gimp`) |
| Steam | apt (i386) | `option` `programs.steam.enable` (handles the 32-bit mess for you) |
| Heroic Games Launcher | flatpak | `flatpak` or `nixpkgs` (`heroic`) |
| Space Cadet Pinball | flatpak | `flatpak` |
| Gopher64 / RMG (N64) | flatpak | `flatpak` |
| CUPS printing | snap `cups` | `option` `services.printing.enable` (no printers configured today) |

## Needs a decision — no clean NixOS route

| Software | Current | Problem |
|---|---|---|
| **Private Internet Access VPN** | `/opt/piavpn`, `/usr/local/bin/piactl`, autostarts | Vendor binary installer; not in nixpkgs as far as I know (**unverified — check `nix search pia` / the NixOS wiki**). Realistic options: (a) use PIA's WireGuard config generator + `networking.wireguard` declaratively, which is arguably nicer, (b) `programs.nix-ld` + the vendor blob, (c) drop it. |
| Docker Desktop | `/opt/docker-desktop` | Drop, as above. |
| JetBrains Toolbox | `~/.local/share/JetBrains/Toolbox` | Use nixpkgs `jetbrains.*` instead. |
| DisplayCAL | config dir present | Check nixpkgs; the old Python-2-era version is troublesome everywhere. |
| Calamares (installer) leftovers | apt | Was pulled in by Kubuntu. Irrelevant on NixOS. |

## Explicitly do NOT carry over

- **snapd and all 28 snaps.** Snap on NixOS is possible but pointless — nixpkgs
  or Flatpak covers every one of them. This also reclaims ~7 GB.
- **PPAs / vendor apt repos** (Docker, eduVPN, Microsoft). Nix replaces all three.
- `~/install.sh` — the eduVPN Debian/Fedora installer script. Dead weight now.
- Ubuntu Pro / ESM holds.
- `linux-image-6.17.0-29` / `7.0.0-15` leftovers, the old kernel-pin machinery.
  On NixOS a kernel pin is one declarative line:
  `boot.kernelPackages = pkgs.linuxPackages_6_12;`

---

## Raw dumps

`raw/` next to this file:

```
hardware.txt          lspci / lscpu / os-release / uname
disks.txt fstab.txt   old partition layout
apt-manual.txt        110 manually installed apt packages
flatpak.txt snap.txt  7 flatpaks, 28 snaps
nm-connections.txt    19 saved WiFi networks + eduVPN
locale-keyboard.txt   locale, timezone, keymap
config-dirs.txt       99 dirs in ~/.config  (what was configured at all)
local-share-dirs.txt  58 dirs in ~/.local/share
docker-images.txt     10 docker images
vscode-extensions.txt 8 VS Code extensions
zshrc.bak p10k.zsh.bak gitconfig.bak ssh-config.bak
```
