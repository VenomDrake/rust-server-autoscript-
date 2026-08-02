#!/usr/bin/env bash

# Copyright (c) 2026 Alessandro De Mitri
# License: MIT
# Source: https://linuxgsm.com/servers/rustserver/

source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/install.func)

set -Eeuo pipefail

setting_up_container
network_check
update_os

msg_info "Installing LinuxGSM prerequisites"
dpkg --add-architecture i386
$STD apt-get update
$STD apt-get install -y \
  bc binutils bsdmainutils bzip2 ca-certificates cron curl distro-info \
  file gzip hostname jq lib32gcc-s1 lib32stdc++6 libsdl2-2.0-0:i386 \
  netcat-openbsd pigz python3 sudo tar tmux unzip util-linux uuid-runtime \
  wget xz-utils
msg_ok "Installed LinuxGSM prerequisites"

msg_info "Creating rustserver service account"
if ! id rustserver &>/dev/null; then
  useradd --create-home --home-dir /home/rustserver --shell /bin/bash rustserver
fi
install -d -o rustserver -g rustserver /home/rustserver
msg_ok "Created rustserver service account"

msg_info "Installing LinuxGSM and Rust Dedicated Server"
printf '%s\n' 'rustserver ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/rustserver-linuxgsm
chmod 0440 /etc/sudoers.d/rustserver-linuxgsm
trap 'rm -f /etc/sudoers.d/rustserver-linuxgsm' EXIT
curl -fsSL https://linuxgsm.sh -o /home/rustserver/linuxgsm.sh
chown rustserver:rustserver /home/rustserver/linuxgsm.sh
chmod 0755 /home/rustserver/linuxgsm.sh
runuser -u rustserver -- bash -c 'cd /home/rustserver && ./linuxgsm.sh rustserver'
runuser -u rustserver -- bash -c 'cd /home/rustserver && ./rustserver auto-install'
rm -f /etc/sudoers.d/rustserver-linuxgsm
trap - EXIT
msg_ok "Installed LinuxGSM and Rust Dedicated Server"

msg_info "Adding recommended scheduled tasks"
cat > /etc/cron.d/rustserver <<'EOF'
*/5 * * * * rustserver /home/rustserver/rustserver monitor >/dev/null 2>&1
*/30 * * * * rustserver /home/rustserver/rustserver update >/dev/null 2>&1
0 0 * * 0 rustserver /home/rustserver/rustserver update-lgsm >/dev/null 2>&1
EOF
chmod 0644 /etc/cron.d/rustserver
systemctl enable --now cron
msg_ok "Added recommended scheduled tasks"

motd_ssh
customize
cleanup_lxc
