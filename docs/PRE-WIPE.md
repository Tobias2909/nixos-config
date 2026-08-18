# Before erasing the disk

Everything on this laptop is a copy of what is on the main desktop PC, so there
is **no backup drive and no bulk copy**. This list is deliberately short.

## Must do

- [ ] **SSH keypair onto the USB stick.** `~/.ssh/id_ed25519` and
      `~/.ssh/id_ed25519.pub`. This is the one irreplaceable thing.
      On the new system restore it with the right permissions or SSH refuses it:
      ```
      mkdir -p ~/.ssh && chmod 700 ~/.ssh
      cp /path/to/stick/id_ed25519* ~/.ssh/
      chmod 600 ~/.ssh/id_ed25519 && chmod 644 ~/.ssh/id_ed25519.pub
      ```
- [ ] **This whole `~/nixos-migration/` folder onto the stick** — including
      `memory/` and `PRIVATE-notes.local.md`, which are *not* in the public repo.
      Without this the kit dies with the disk.
- [ ] Optional insurance: flash drives fail. Pushing the sanitized repo to
      GitHub from this machine before the wipe costs one minute. Not required —
      the plan is to create the repo on the new system.

## Decide — five minutes, then move on

- [ ] **GPG key.** It only exists here. If signed commits or encrypted mail with
      the *same* key matter, export it now:
      ```
      gpg --export-secret-keys --armor <keyid> > gpg-secret.asc
      gpg --export-ownertrust > ownertrust.txt
      ```
      and put both on the stick. Otherwise generate a fresh key on NixOS and
      upload the new public key wherever the old one was registered.
      Key ID is in `PRIVATE-notes.local.md`.
- [ ] **Coursework.** `~/claude` (the ITSAI lab: Caddyfile, docker-compose, app/,
      certs/, aufgabe5.md) is not a git repo. Confirm it exists on the desktop PC
      or on the university VM, or copy it to the stick. Same for
      `~/IdeaProjects/AdventOfCode`.
- [ ] **Unpushed commits.** In `~/RiderProjects/verteilter-schuhladen` and
      `~/IdeaProjects/gka_praktikum1`:
      ```
      git status --short && git log --branches --not --remotes --oneline
      ```
      Empty output from the second command means everything is on the remote.

## Explicitly not doing

Steam library, Docker images, VirtualBox `Win11` VM, `~/Videos`, `~/Music`,
`~/Documents/Software`, `~/.local` (JetBrains installs), browser profiles,
saved WiFi passwords, `~/.msmtprc`, `PiBackup.img` — all duplicated on the
desktop PC or re-downloadable. Gone on purpose.

## Sanity check before `dd`

Two sticks: **stick A** holds the files (stays a normal filesystem, never
`dd`-ed), **stick B** gets the ISO written over it.

- [ ] Copy the files to stick A and **unmount it, then unplug it** before you
      touch `dd`. This is the whole reason for using two sticks.
- [ ] Identify stick B with `lsblk` **immediately before writing** — device
      names move between boots, and `dd` to the wrong device is unrecoverable.
- [ ] The SSH key on the stick is readable: `ssh-keygen -y -f /path/to/id_ed25519`
      prints a public key. Presence in a file listing is not the same as valid.
- [ ] BIOS: UEFI, Secure Boot off. Already correct, nothing to change.
