#!/bin/bash

function error {
	if [ -e "$RESULTS" ]; then
		echo $* >>$RESULTS/log
	fi
	echo "	$*" 1>&2
	exit 1
}

function log {
	echo $* >>$RESULTS/log
	if [ "$VERBOSE" ]; then
		echo "$*"
	fi
}
