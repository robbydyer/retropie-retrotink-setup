#!/bin/bash
set -euo pipefail

# Check if running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root! Please run like \`sudo $0\`"
  exit 1
fi

PIE_HOME=/home/pi/RetroPie
MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if ps faux | grep emulationstation | grep -v grep; then
  killall emulationstation
fi

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
  echo "FILE => ${dest_file}"

  # /boot is special
  if [[ "${dest_file}" == /boot/* ]]; then
    cp "${source_file}" "${dest_file}"
    chown root:root "${dest_file}"
    continue
  fi

  # Ensure dest dir exists
  dir="$(dirname "${dest_file}")"
  if [ ! -d "${dir}" ]; then
    mkdir -p "${dir}"
    chown pi:pi "${dir}"
  fi

  cp "${source_file}" "${dest_file}"
  chown pi:pi "${dest_file}"
done

# Special case for hidden directories, like /home/pi/.emulationstation
for src_dir in $(find . -type d -name ".*"); do
  dest_dir="${src_dir:1}"
  echo "DIR => ${dest_dir}"
  if [ ! -d "${dest_dir}" ]; then
    mkdir -p "${dest_dir}"
  fi
  cp -r "${src_dir}/*" "${dest_dir}/"
  chown pi:pi "${dest_dir}"
done

if ! grep -lq 'SaveStates' /etc/samba/smb.conf; then
  echo "=> Writing samba config"
  cat >> /etc/samba/smb.conf <<EOF
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

# Set current theme to mine
echo "=> Setting theme to carbon-nometa-240p"
themefile=/home/pi/.emulationstation/es_settings.cfg
sed '\,<string name="ThemeSet" value=".*" />,d' -i "${themefile}"
echo '<string name="ThemeSet" value="carbon-nometa-240p" />' >> "${themefile}"

# Install extra packages needed for helper scripts
apt-get update
apt-get install -y ffmpeg libav-tools

sync
sync
echo "Setup complete! Please reboot your system"
