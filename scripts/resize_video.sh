#!/bin/bash
set -euox pipefail

if [ -z "${1:-}" ]; then
	echo "Pass source video filename as arg 1"
	exit 1
fi
source="$1"
test -f "${source}"

base="$(basename "${source}")"
tmpfile="/tmp/${base}"
cp "${source}" "${tmpfile}"

avconv -y -i "${tmpfile}" -s 320x240 "${source}"
