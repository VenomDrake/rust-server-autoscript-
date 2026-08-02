#!/usr/bin/env bash

# Copyright (c) 2026 Alessandro De Mitri
# License: MIT
# Source: https://linuxgsm.com/servers/rustserver/

source <(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)

APP="Rust Dedicated Server"
var_tags="${var_tags:-gaming;linuxgsm;rust}"
var_cpu="${var_cpu:-4}"
var_ram="${var_ram:-12288}"
var_disk="${var_disk:-30}"
var_os="${var_os:-ubuntu}"
var_version="${var_version:-24.04}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if ! pct exec "$CTID" -- test -x /home/rustserver/rustserver; then
    msg_error "No LinuxGSM Rust installation found in CT $CTID"
    exit 1
  fi

  msg_info "Updating LinuxGSM and Rust Dedicated Server"
  pct exec "$CTID" -- runuser -u rustserver -- /home/rustserver/rustserver update-lgsm
  pct exec "$CTID" -- runuser -u rustserver -- /home/rustserver/rustserver update
  msg_ok "Updated LinuxGSM and Rust Dedicated Server"
  exit
}

start
build_container
description

msg_ok "Completed successfully!"
echo -e "${CREATING}${GN}${APP} is ready.${CL}"
echo -e "${INFO}${YW} Manage it with: pct exec ${CTID} -- runuser -u rustserver -- /home/rustserver/rustserver <command>${CL}"
