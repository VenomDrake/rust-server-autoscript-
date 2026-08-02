# Rust Dedicated Server LXC for Proxmox VE

Community Scripts-style installer that creates an unprivileged Ubuntu 24.04
LXC and installs the Rust Dedicated Server (Steam App ID `258550`) through
[LinuxGSM](https://linuxgsm.com/servers/rustserver/).

## Quick start

Run this command in the Proxmox VE shell:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/OWNER/rust-server-autoscript-/main/ct/rust-server.sh)"
```

Replace `OWNER` with the GitHub account or organization hosting your fork.
The defaults are 4 CPU cores, 12 GiB RAM, a 30 GiB disk, Ubuntu 24.04, and an
unprivileged container. The advanced settings offered by `build.func` can be
used to override them before creation.

> Rust downloads a large amount of game data. Make sure the selected Proxmox
> storage has enough free space and that the container has internet access.

## Server administration

LinuxGSM runs under the passwordless, non-login administration account
`rustserver`. From the Proxmox host, use:

```bash
pct exec <CTID> -- runuser -u rustserver -- /home/rustserver/rustserver start
pct exec <CTID> -- runuser -u rustserver -- /home/rustserver/rustserver stop
pct exec <CTID> -- runuser -u rustserver -- /home/rustserver/rustserver restart
pct exec <CTID> -- runuser -u rustserver -- /home/rustserver/rustserver details
pct exec <CTID> -- runuser -u rustserver -- /home/rustserver/rustserver console
```

Detach from the console with `Ctrl+B`, then `D`. Server and LinuxGSM logs are
stored in `/home/rustserver/logs` inside the container.

The installer also creates the LinuxGSM-recommended cron jobs for monitoring
(every 5 minutes), game updates (every 30 minutes), and LinuxGSM updates
(weekly). The Community Scripts update action runs both `update-lgsm` and
`update` on demand.

## Files

- `ct/rust-server.sh`: Proxmox VE entry point and `build.func` integration.
- `install/rust-server-install.sh`: in-container LinuxGSM installation.

## License

MIT
