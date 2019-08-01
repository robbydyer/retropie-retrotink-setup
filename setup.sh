#!/bin/bash
set -euo pipefail

# Check if running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root! Please run like \`sudo $0\`"
  exit 1
fi

PIE_HOME=/home/pi/RetroPie
MY_DIR= "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

killall emulationstation

# Create savestates/savefiles dirs for each system
for system in $(find "${PIE_HOME}/roms" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;); do
  mkdir -p "${PIE_HOME}/savefiles/${system}"
  mkdir -p "${PIE_HOME}/savestates/${system}"
done

chown -R pi:pi "${PIE_HOME}/savefiles"
chown -R pi:pi "${PIE_HOME}/savestates"

cd "${MY_DIR}/files"
for source_file in $(find . -type f); do
  dest_file="${source_file:1}"
  cp "${source_file}" "${dest_file}"
  chown pi:pi "${dest_file}"
done

if ! grep "[SaveStates]" /etc/samba/smb.conf; then
  cat <<EOF >> /etc/samba/smb.conf
[SaveStates]
comment = pi
path = "/home/pi/RetroPie/savestates"
writeable = yes
guest ok = yes
create mask = 0644
directory mask = 0755
force user = pi
follow symlinks = yes
wide links = yes
[SaveFiles]
comment = pi
path = "/home/pi/RetroPie/savefiles"
writeable = yes
guest ok = yes
create mask = 0644
directory mask = 0755
force user = pi
follow symlinks = yes
wide links = yes
EOF
fi

sync
sync
echo "Setup complete! Please reboot your system"
