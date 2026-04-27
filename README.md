# Linux Configuration

Post-installation configuration scripts for Ubuntu 24.04. Automates the setup of a daily-use workstation: development tools, security utilities, shell environment, desktop applications, and system hardening.

## Prerequisites

- Ubuntu 24.04
- Root access
- Internet connection

## Usage

Run from inside the `ubuntu/` directory:

```bash
sudo bash pre-install.sh            # base workstation setup
sudo bash pre-install.sh --laptop   # base setup + laptop-specific apps
```

`pre-install.sh` is the entry point. It bootstraps the system, then calls `install.sh`. The `--laptop` flag additionally runs `laptop.sh`.

## What gets installed

**CLI tools** — git, tmux, vim, zsh, nmap, netcat, socat, wireshark, ripgrep, jq, fzf, bat, eza, parallel, foremost, binwalk, ffmpeg, and more.

**GUI tools** — Flameshot, Wireshark, Meld, GParted, Ghex, VLC, LibreOffice, Audacity, Okular.

**Applications** — Brave Browser, VS Code (with extensions from `config/extensions.txt`), OnlyOffice, Glow, Docker.

**Shell** — Zsh with Oh My Zsh, autosuggestions, syntax highlighting, fzf integration. Shell config and aliases are deployed from `config/zshrc` and `config/aliases`.

**Laptop extras** (`--laptop`) — Discord, Signal Desktop, CameraCtrls.

**System hardening** — UFW firewall (deny incoming, allow SSH), SSH configured to reject root password login, Fastfetch on login.

## Notes

- Scripts use `set -euo pipefail`. Any failed command will stop the script.
- Most operations are idempotent; re-running is safe.
- A logout is required after the first run for the Zsh shell change to take effect.

# Disclaimer

These scripts modify system configuration, install many packages, and change security settings.
Review them carefully before running on a production or sensitive machine.

---

# Thanks to

- <https://github.com/laluka/lalubuntu>
- <https://github.com/laluka/SkillArch>