# Next steps

Plan of record (2026-08-18): copy files to stick A → write ISO to stick B →
install NixOS → install Claude Code → copy files back → then build the config
and create the GitHub repo, with Claude Code, on the new system.

Nothing on this laptop is being preserved except the SSH keypair and this folder.

---

## Step 1 — Stick A: the files (do this first, while the old system lives)

```sh
# find the stick
lsblk -o NAME,SIZE,TYPE,TRAN,MODEL,MOUNTPOINT | grep -v loop

# copy — adjust the mount path to whatever the stick actually mounts as
DEST=/run/media/$USER/<STICK-A-LABEL>
cp -a ~/nixos-migration "$DEST"/
mkdir -p "$DEST"/ssh-key
cp ~/.ssh/id_ed25519 ~/.ssh/id_ed25519.pub "$DEST"/ssh-key/

# verify the key is intact, not just present
ssh-keygen -y -f "$DEST"/ssh-key/id_ed25519 | head -c 60; echo

sync && udisksctl unmount -b /dev/<stick-A-partition>
```

`~/nixos-migration` already contains `memory/` and `PRIVATE-notes.local.md`,
neither of which will be in the public repo. That is the point of copying the
whole folder rather than cherry-picking.

Then work through **`PRE-WIPE.md`** — it is short, mostly the GPG decision and a
check that the coursework in `~/claude` exists elsewhere.

**Unplug stick A before step 2.** Do not have it connected while running `dd`.

## Step 2 — Stick B: the ISO

Current stable is **NixOS 26.05**. The graphical ISO includes KDE Plasma; the
desktop you pick in the live boot menu does not constrain what you install.

```sh
cd ~/Downloads

# The "latest-*" URL is a redirect. Resolve it first, so the downloaded file
# is named the same as the name recorded inside the .sha256 file — otherwise
# `sha256sum -c` fails with "No such file or directory".
ISO_URL=$(curl -sIL -o /dev/null -w '%{url_effective}' \
  https://channels.nixos.org/nixos-26.05/latest-nixos-graphical-x86_64-linux.iso)
echo "$ISO_URL"          # expect .../nixos-graphical-26.05.<rev>-x86_64-linux.iso

curl -LO "$ISO_URL"
curl -LO "$ISO_URL.sha256"
sha256sum -c "$(basename "$ISO_URL").sha256"
```

Only continue if that prints `OK`. Verified working 2026-08-18; the release at
that point was `nixos-graphical-26.05.7813.0dd31db7e6db-x86_64-linux.iso` (~an
ISO of a few GB, so the 7.6 GB stick is fine).

```sh
# IDENTIFY THE TARGET IMMEDIATELY BEFORE WRITING — names move between boots
lsblk -o NAME,SIZE,TYPE,TRAN,MODEL,MOUNTPOINT | grep -v loop

# unmount any partition of the target stick first (not the whole disk)
udisksctl unmount -b /dev/sdX1

# write it — sdX is the DISK (no number). This erases the stick.
sudo dd if="$(basename "$ISO_URL")" of=/dev/sdX \
        bs=4M status=progress oflag=sync conv=fsync
```

Check `lsblk` twice. `dd` to `/dev/nvme0n1` would destroy the running system with
no confirmation and no undo.

## Step 3 — Install

1. Reboot, **F12** for the Dell one-time boot menu, pick the USB stick under UEFI.
2. Firmware is already UEFI with Secure Boot off — nothing to change in BIOS.
3. If the live session hangs on boot because of the hybrid GPU, add `nomodeset`
   to the kernel command line from the boot menu. Usually the Intel iGPU drives
   the installer without help.
4. In the installer: choose **KDE Plasma** as the desktop, keyboard **de**,
   timezone **Europe/Berlin**, locale **en_US.UTF-8**.
5. Partitioning — do it manually rather than "erase disk":
   - **1 GB** ESP, `vfat`, mounted at `/boot`
   - remainder: **LUKS-encrypted**, `ext4`, mounted at `/`
   - swap: an 8–16 GB swapfile, or skip it and enable zram later. The old
     512 MB swapfile was undersized.
   Set the LUKS passphrase somewhere you will not lose it — there is no recovery.
6. Create the user, let it finish, reboot into a plain working Plasma system.
   **Do not** try to boot straight into a custom flake. Get boring first.

## Step 4 — First minutes on NixOS

```sh
# 1. Verify the basics before changing anything
nixos-version
nvidia-smi                      # NVIDIA reachable?
systemctl suspend               # and does it come back? (the old sore point)

# 2. Restore the SSH key from stick A
mkdir -p ~/.ssh && chmod 700 ~/.ssh
cp /run/media/$USER/<STICK-A>/ssh-key/id_ed25519* ~/.ssh/
chmod 600 ~/.ssh/id_ed25519 && chmod 644 ~/.ssh/id_ed25519.pub
ssh -T git@github.com           # expect "successfully authenticated"

# 3. Copy the kit back
cp -a /run/media/$USER/<STICK-A>/nixos-migration ~/

# 4. Restore the memories so the next Claude Code session has context
mkdir -p ~/.claude/projects/-home-tobias-claude/memory
cp -a ~/nixos-migration/memory/. ~/.claude/projects/-home-tobias-claude/memory/
```

Note that step 2 and 3 need the stick mounted, and step 4's path assumes the same
username and working directory as before. If either changed, adjust the path —
the memory directory name is derived from the project directory path.

## Step 5 — Install Claude Code

Nix has it packaged, but on a fresh system without a flake yet the quickest route
is a temporary shell:

```sh
nix-shell -p claude-code          # throwaway, nothing installed permanently
```

Or the official installer, which lands in `~/.local/bin` and needs
`programs.nix-ld.enable = true` if it turns out to be a dynamically linked
binary. Adding `claude-code` to the flake properly is a step-6 job.

## Step 6 — Then hand it back to me

Open Claude Code in `~/nixos-migration` and say roughly:

> I'm on fresh NixOS now. Read HANDOVER.md and SOFTWARE.md, then help me build
> the flake and create the public GitHub repo.

What happens then, in order:

1. Read `/etc/nixos/hardware-configuration.nix` — the installer generated it and
   it is the one file that must be preserved verbatim.
2. Build a minimal `flake.nix`: `nixpkgs` (26.05) + `nixos-hardware`, pulling in
   `dell-xps-15-7590-nvidia`.
3. `sudo nixos-rebuild switch --flake ~/nixos-config#tblpt` — verify the plain
   system still boots and suspends.
4. Create the **public** GitHub repo, commit, push. Confirm `.gitignore` is in
   place and that `memory/` and `PRIVATE-notes.local.md` are excluded *before*
   the first push, not after.
5. Then, one commit at a time, the things that actually matter:
   easyroam → eduVPN → SSH → texlive. Nothing else until those four work.

Do not batch step 5. One package, one rebuild, one commit.

---

## The uni-critical checklist

The migration is not "done" until all four pass. Ideally before the next lecture.

- [ ] **easyroam** — connect to campus WiFi (`easyroam-connect-desktop`, or the
      Flatpak, or `nix-easyroam`). See `HANDOVER.md` §2.
- [ ] **eduVPN** — expect the `Expected one openvpn VPN plugins, got: 0` bug;
      the fix to try is `networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ]`.
- [ ] **SSH to the university hosts** with the restored key.
- [ ] **TeXStudio + texlive** — compile one old lab report end to end.

If easyroam, eduVPN, or NVIDIA/suspend cannot be made to work in a weekend,
Fedora KDE is the fallback and that is a legitimate outcome, not a failure.
