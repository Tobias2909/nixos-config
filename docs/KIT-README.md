# NixOS migration kit — tblpt (Dell XPS 15 7590)

Captured 2026-08-18 from the outgoing Kubuntu 26.04 install.
Target: NixOS 26.05 + KDE Plasma 6, system config in a public GitHub repo.

| File | What it is |
|---|---|
| **`NEXT-STEPS.md`** | The actual procedure: sticks, ISO, install, first commands. **Start here.** |
| `PRE-WIPE.md` | The short list of things to handle before erasing the disk. |
| `HANDOVER.md` | Machine memoire: hardware, settings to reproduce, easyroam/eduVPN findings, Nix gotchas. |
| `SOFTWARE.md` | Reference list of what the old system had. **Not a to-install list** — every package on the new system is chosen individually. |
| `raw/` | Unedited command output: package lists, hardware dump, dotfile copies. |

## Not in this repo

`.gitignore` excludes `PRIVATE-notes.local.md` (university account, internal
hosts, key fingerprints) and `memory/` (Claude Code context). Both travel on the
USB stick instead. The tracked files carry no credentials, no certificates, no
account names, no internal hostnames or IPs, and no WiFi history.

If you ever add an easyroam PKCS#12 for the declarative route, encrypt it with
sops-nix or agenix. It is a client credential, not a config file.

## Ground rule

The old system accumulated 110 apt packages, 28 snaps and 7 Flatpaks over years.
The new one starts near-empty and grows one deliberate commit at a time.
`SOFTWARE.md` exists to answer "what was I using again?", not to be replayed.
