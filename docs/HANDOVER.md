# tblpt → NixOS: Handover / Machine Memoire

Written 2026-08-18 on the running Kubuntu system, before the wipe.
Purpose: everything needed to rebuild this laptop (or a replacement) from scratch.

**Public repo.** Identifying details (university account, internal hosts, key
fingerprints, WiFi history) were deliberately kept out. They live in
`PRIVATE-notes.local.md`, which is gitignored — see `.gitignore`.

Read `NEXT-STEPS.md` for what to do right now. `SOFTWARE.md` is the reference
list of what used to be installed. `PRE-WIPE.md` is the short list of things to
handle before erasing the disk.

---

## 1. The machine

| | |
|---|---|
| Hostname | `tblpt` |
| Model | Dell XPS 15 7590 (SKU 0905, rev A00) |
| BIOS/firmware | 1.42.0 |
| CPU | Intel Core i7-9750H (6C/12T) |
| RAM | 16 GB |
| GPU | Hybrid: Intel UHD 630 (`i915`) + NVIDIA GTX 1650 Mobile / Max-Q, TU117M `[10de:1f91]` |
| Disk | Samsung PM981a, 512 GB NVMe (`nvme0n1`) |
| WiFi | Intel AX200 (Killer AX1650x), `iwlwifi` |
| Firmware mode | **UEFI**, Secure Boot **disabled** |

### Old partition layout (reference — do NOT replicate)
```
nvme0n1p1   300M  vfat  /boot/efi
nvme0n1p2   477G  ext4  /            (unencrypted)
/swapfile   512M  swap
```

Two deliberate changes on reinstall:

1. **ESP of 1 GB, not 300 MB.** NixOS with systemd-boot stores every
   generation's kernel + initrd in the ESP. 300 MB fills up after a handful of
   generations and rebuilds then fail. 1 GB is the comfortable default.
2. **LUKS full-disk encryption.** The old install was unencrypted. This laptop
   leaves the house and holds SSH keys to university infrastructure. Encrypt it.

---

## 2. The good news, up front

Three things that could have made NixOS painful on this hardware are already solved:

1. **nixos-hardware has an exact module for this laptop:**
   `nixos-hardware.nixosModules.dell-xps-15-7590-nvidia`
   It handles the Intel-RAID→AHCI issue, adds systemd-boot to the UEFI boot
   list, and forces **deep sleep** instead of the default s2idle — precisely the
   suspend-drain / suspend-panic class of problem that cost time on Kubuntu.
2. **easyroam is packaged for NixOS** as `easyroam-connect-desktop` in nixpkgs
   (1.4.x). There is also a declarative community module,
   `github:einetuer/nix-easyroam`, which takes the PKCS#12 file from the easyroam
   portal and wires up NetworkManager or wpa_supplicant. And the fallback always
   works: the **Flatpak** `de.easyroam.easyroam` is what the old system used, and
   Flatpak runs fine on NixOS.
3. **eduVPN is packaged** as `eduvpn-client`.

### How easyroam was actually wired up (the important bit)

The easyroam client does nothing magic. It logs in to the university portal,
receives a client certificate, writes it to disk, and creates an ordinary
NetworkManager **EAP-TLS** connection pointing at those files:

```
connection.id       easyroam
802-1x.eap          tls
802-1x.identity     <numeric-id>@easyroam-pca.<university>   (issued at login)
802-1x.client-cert  ~/.var/app/de.easyroam.easyroam/data/de.dfn.easyroam/cert.pem
802-1x.private-key  ~/.var/app/de.easyroam.easyroam/data/de.dfn.easyroam/key.pem
802-1x.ca-cert      (unset)
```

Three routes on NixOS, easiest first:

- **A:** install `easyroam-connect-desktop` (or the Flatpak), log in with the
  university account, let it generate a fresh certificate. Same as before.
- **B:** the `nix-easyroam` flake module + a PKCS#12 downloaded from the easyroam
  portal ("Manual Options" → PKCS12). Fully declarative; certs are extracted to
  `/run/easyroam/`. **If the .p12 goes anywhere near this repo it must be
  encrypted with sops-nix or agenix** — it is a client credential.
- **C:** build the EAP-TLS connection by hand in KDE's network settings using the
  table above plus a freshly issued cert/key pair.

Old certificates expire, and the identity is reissued on login, so regenerating
is the normal path — there is nothing to carry over.

### Known eduVPN gotcha

nixpkgs issue #424326 (open, reported 2025-07): `eduvpn-client` fails with
`Expected one openvpn VPN plugins, got: 0`. Cause is the missing NetworkManager
OpenVPN plugin. First thing to try:

```nix
networking.networkmanager = {
  enable = true;
  plugins = with pkgs; [ networkmanager-openvpn ];
};
```
(`networking.networkmanager.plugins` is a real option, default `[]`.)
Unverified on this hardware — test it early, it blocks university work.

---

## 3. Credentials and identity — what to do, not what they are

The only thing being carried across the wipe is the **SSH keypair**
(`~/.ssh/id_ed25519` + `.pub`), copied manually to the USB stick. Everything
else on the old disk is a duplicate of the main desktop PC and is being let go.

Consequences to be aware of, so nothing is a surprise later:

| Thing | Status after the wipe |
|---|---|
| SSH keypair | carried on the USB stick; restore to `~/.ssh/` with mode `600` |
| SSH config (university hosts) | gone — recorded in `PRIVATE-notes.local.md`, also re-derivable from the university's documentation |
| GPG keypair | **gone unless exported.** If the same key matters (signed commits, encrypted mail), export it before wiping: `gpg --export-secret-keys --armor <keyid> > gpg-secret.asc` plus `gpg --export-ownertrust > ownertrust.txt`. Otherwise generate a fresh key on NixOS and upload the new public key. |
| KeePassXC database | copy exists on the desktop PC |
| Saved WiFi networks (19) | gone; re-enter as needed. Nothing worth preserving. |
| `~/.msmtprc` mail credentials | gone; reconfigure from the password manager |
| easyroam certificate | regenerated by logging in |
| eduVPN state | regenerated on first connect |
| Browser profiles | use account sync, or accept the loss |

After restoring the key, re-test it against the university hosts and GitHub
before assuming it still works.

---

## 4. System settings to reproduce

```
Timezone      Europe/Berlin
LANG          en_US.UTF-8
LC_* (most)   de_DE.UTF-8
Keyboard      layout de, model pc105, no variant
Shell         zsh, user uid 1000
Desktop       KDE Plasma
  look&feel   org.kde.breezedark.desktop
  icons       Breeze-Chameleon Light   (a Nordzy-icon clone also sat in ~/)
```

NixOS equivalent sketch:

```nix
time.timeZone = "Europe/Berlin";
i18n.defaultLocale = "en_US.UTF-8";
i18n.extraLocaleSettings = {
  LC_NUMERIC = "de_DE.UTF-8"; LC_TIME = "de_DE.UTF-8";
  LC_MONETARY = "de_DE.UTF-8"; LC_PAPER = "de_DE.UTF-8";
  LC_NAME = "de_DE.UTF-8"; LC_ADDRESS = "de_DE.UTF-8";
  LC_TELEPHONE = "de_DE.UTF-8"; LC_MEASUREMENT = "de_DE.UTF-8";
  LC_IDENTIFICATION = "de_DE.UTF-8";
};
services.xserver.xkb.layout = "de";
console.keyMap = "de";
services.desktopManager.plasma6.enable = true;
services.displayManager.sddm.enable = true;
users.users.<user> = {
  isNormalUser = true;
  shell = pkgs.zsh;
  extraGroups = [ "wheel" "networkmanager" ];   # add docker/vboxusers only if used
};
programs.zsh.enable = true;   # required, or the login shell above is broken
```

### Shell environment (zsh)

Old setup: oh-my-zsh (plugins: git, fzf, extract) + powerlevel10k +
zsh-autosuggestions + zsh-syntax-highlighting + zsh-history-substring-search,
`fastfetch` on interactive start, `~/.p10k.zsh` (copied to `raw/p10k.zsh.bak`).

Aliases worth keeping — the apt ones need rewriting:

```
c=clear   please=sudo   jctl='journalctl -p 3 -xb'   tb='nc termbin.com 9999'
make='make -j$(nproc)'
update  -> was: sudo apt update && sudo apt upgrade
            now: sudo nixos-rebuild switch --flake ~/nixos-config#tblpt
cleanup -> was: sudo apt autoremove
            now: sudo nix-collect-garbage -d
```

On NixOS prefer `programs.zsh.ohMyZsh` / `.autosuggestions` /
`.syntaxHighlighting` over the hand-cloned git repos the old system used.

### Git

`core.autocrlf = input`. Name and email: set fresh (they were `<name>` and a
university address; see `raw/gitconfig.bak` for the shape).

---

## 5. Suggested repo layout

```
nixos-config/
├── flake.nix              # inputs: nixpkgs, nixos-hardware, (home-manager later)
├── flake.lock             # COMMIT THIS — it is the reproducibility guarantee
├── hosts/
│   └── tblpt/
│       ├── default.nix    # hostname, user, locale, desktop
│       └── hardware-configuration.nix   # from nixos-generate-config
├── modules/
│   ├── desktop.nix        # plasma6, sddm, fonts, flatpak
│   ├── dev.nix            # docker, editors, toolchains
│   ├── uni.nix            # easyroam, eduvpn, texlive
│   └── gaming.nix         # easy to comment out
├── docs/                  # this kit
└── README.md              # the five commands you will forget
```

That `README.md` matters more than it looks. This laptop gets used four times a
week or not for months. Write down in plain words: how to add a package, how to
rebuild, how to roll back, how to update, how to garbage-collect.

---

## 6. Nix-specific things that will bite you

- **`nix-collect-garbage -d`** is not optional. Every rebuild keeps the previous
  system. On a rarely-used machine, run it after each update round or the Nix
  store quietly eats the disk.
- **`nixos-rebuild boot` vs `switch`.** `switch` activates immediately; `boot`
  applies at next reboot. For kernel/driver changes, `boot` + reboot is cleaner.
- **Stable, not unstable.** Take the current stable channel and bump it at
  semester boundaries. Unstable means more surprises on a machine you touch
  infrequently — the opposite of what this machine needs.
- **Imperative installs do not work.** No `./configure && make install`, no
  downloaded `.deb`, no vendor install script. For stubborn prebuilt binaries:
  `programs.nix-ld.enable = true` or an FHS wrapper.
- **Flatpak is the pressure-release valve.** `services.flatpak.enable = true;`
  The old system already ran seven Flatpaks, so this is a familiar pattern
  rather than a compromise.
- **`flake.lock` is the reproducibility.** Commit it. Without it, "same repo"
  does not mean "same system".
- **Secure Boot stays off.** Turning it on later means `lanzaboote`, which is not
  a beginner project.
