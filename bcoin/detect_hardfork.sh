#!/bin/bash
shopt -s nullglob
set -o nounset

if [ "$#" -ne 1 ] ; then
	echo "Usage: $0 DIRECTORY" >&2
	exit 1
fi

FILES=$1/*
for filename in $FILES; do
	echo "---"
	bitcoincore=$(../valid_script $filename 2)
	bcoin=$(node valid_script.js $filename);
	if [[ $bitcoincore == $bcoin ]]; then
		echo "success"
	else
		echo "failed bcoin: ${bcoin} bitcoincore: ${bitcoincore} file: ${filename}"
	fi
done
