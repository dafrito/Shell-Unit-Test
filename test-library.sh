#!/bin/bash

function die {
	echo "[DIE] $*" 1>&2
	exit 1
}

function equals {
	if [ "$1" = "$2" ]; then
		return 0;
	fi
	ERR="[tst] Unequal values: Expected '$1', got '$2'"
	if [ "$3" ]; then
		shift 2
		ERR="$ERR for assertion '$*'"
	fi
	die $ERR
}

function expect {
	MSG=$1
	shift
	if $* 2>&1; then
		die "[tst] Expected failure, but got success. Assertion '$MSG'"
	fi
}
