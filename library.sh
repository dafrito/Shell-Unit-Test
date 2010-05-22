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

function assert_tests {
	if [ ! -d tests ]; then
		if [ -d ../tests ]; then
			# It's common that we're working in ./tests, so we support this one case.
			cd ..
		else
			error "no tests found";
		fi
	fi
}

