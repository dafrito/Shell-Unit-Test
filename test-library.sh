#!/bin/bash

function die {
	if [ -n "$ERR" ]; then
		echo "[ERR] $ERR" 1>&2
	fi
	echo "[DIE] $*" 1>&2
	exit 1
}

function equals {
	unset ERR
	expected=$1
	shift
	actual=$*
	if [ "$expected" = "$actual" ]; then
		return 0
	fi
	ERR="Unequal values: Expected '$1', got '$2'"
	return 1
}

function expect {
	unset ERR
	if $* 2>&1; then
		ERR="Expected failure, but got success."
		return 1
	fi
	return 0
}
