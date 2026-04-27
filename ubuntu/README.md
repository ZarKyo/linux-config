# Ubuntu

See the [repository README](../README.md) for full documentation.

## Scripts

| Script | Role |
|---|---|
| `pre-install.sh` | Entry point. Bootstrap, then calls `install.sh` (and `laptop.sh` with `--laptop`). |
| `install.sh` | Core installation: CLI/GUI tools, Brave, VS Code, Zsh, UFW, SSH hardening. |
| `laptop.sh` | Optional. Discord, Signal Desktop, CameraCtrls. |

## Config files

| File | Deployed to |
|---|---|
| `config/zshrc` | `~/.zshrc` |
| `config/aliases` | `~/.aliases` |
| `config/extensions.txt` | VS Code extension list |
