#!/bin/bash
NEW_ROM="$1"
if [ -z "$NEW_ROM" ]; then
	echo "correct usage: ./switchrom.sh [NEW_ROM]"
	exit 1
fi
echo "writing $NEW_ROM to instmem.dat"
echo "$(cat $NEW_ROM)" > "instmem.dat"
