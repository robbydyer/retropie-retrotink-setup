#!/bin/bash
set -euo pipefail

# Check if running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root! Please run like \`sudo $0\`"
  exit 1
fi

PIE_HOME=/home/pi/RetroPie
MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PACKAGES=(ffmpeg libav-tools)

if ps faux | grep emulationstation | grep -v grep; then
  killall emulationstation
fi

# Create savestates/savefiles dirs for each system
for system in $(find "${PIE_HOME}/roms" -maxdepth 1 -mindepth 1 -type d -exec basename {} \;); do
  for d in savefiles savestates; do
    dir="${PIE_HOME}/${d}/${system}"
    if [ -d "${dir}" ]; then
      echo "SKIP => ${dir} already exists"
    else
      echo "=> Creating ${dir}"
      mkdir -p "${dir}"
    fi

    if [ $(find "${dir}" -mindepth 0 -maxdepth 0 -user pi -type d | wc -l) -lt 1 ]; then
      echo "=> Setting owner on ${dir}"
      chown -R pi:pi "${dir}"
    else
      echo "SKIP => Owner for ${dir} already set to pi"
    fi
  done
done

cd "${MY_DIR}/files"
for source_file in $(find . -type f); do
  dest_file="${source_file:1}"

  # Only overwrite files if they have changed
  if [ -f "${dest_file}" ]; then
    src_sum=$(md5sum "${source_file}" | awk '{print $1}')
    dest_sum=$(md5sum "${dest_file}" | awk '{print $1}')
    if [ "${src_sum}" = "${dest_sum}" ]; then
      echo "SKIP => ${dest_file}"
      continue
    fi
  fi
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
else
  echo "SKIP => Samba config already updated, skipping"
fi

# Set current theme to mine
themefile=/home/pi/.emulationstation/es_settings.cfg
if ! grep -ql '<string name="ThemeSet" value="carbon-nometa-240p" />' "${themefile}"; then
  echo "=> Setting theme to carbon-nometa-240p"
  sed '\,<string name="ThemeSet" value=".*" />,d' -i "${themefile}"
  echo '<string name="ThemeSet" value="carbon-nometa-240p" />' >> "${themefile}"
else
  echo "SKIP => Theme already set, skipping"
fi

# Add bash profile
if ! grep -lq '~/.my_profile.sh' /home/pi/.bashrc; then
  echo "=> Updating ~/.bashrc"
  echo "[ -f ~/.my_profile.sh ] && . ~/.my_profile.sh" >> /home/pi/.bashrc
else
  echo "SKIP => ~/.bashrc already includes our profile, skipping"
fi

# Install extra packages needed for helper scripts
function join_by { local IFS="$1"; shift; echo "$*"; }
grplist=$(join_by "|" "${PACKAGES[@]}")
if [ $(dpkg -l | egrep "${grplist}" | wc -l) -lt "${#PACKAGES[@]}" ]; then
  echo "=> Installing packages"
  apt-get update
  apt-get install -y "${PACKAGES[@]}"
else
  echo "SKIP => Packages already installed, skipping"
fi

sync
sync
echo "Setup complete! Please reboot your system"
