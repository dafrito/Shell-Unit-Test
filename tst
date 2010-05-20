#!/bin/bash
PATH=/bin:/usr/bin:$HOME/bin

TESTS=./tests
TST_ROOT=./result

function error {
	echo $* | tee -a $TST_ROOT/log 1>&2
	exit 1
}

function log {
	if [ "$VERBOSE" ]; then
		echo $* | tee -a $TST_ROOT/log
	fi
}

while [ "$1" ]; do
	case "$1" in
		c|clean)	
			if [ -n "$TST_ROOT" ]; then
				rm -rf  $TST_ROOT*
			fi
			exit
			;;
		-k)	KEEP=true ;;
		-v)	VERBOSE=true ;;
		-*)
			error "Unsupported option: $1"
	esac
	shift
done

total=0
success=0
failed=0

if [ -e $TST_ROOT ]; then
	mv $TST_ROOT $TST_ROOT-`cat $TST_ROOT/timestamp`
fi
mkdir -p $TST_ROOT
touch $TST_ROOT/log

[ -d tests ] || error "no tests found";

function run_test {
	$TEST_ROOT/test
	RESULT=$?
}

date +%Y.%m.%d-%H.%M.%S >$TST_ROOT/timestamp
for i in `find tests -type f ! -name '.*'`; do
	let total++
	log "[tst] $total. $i"
	TEST_ROOT=$TST_ROOT/$total
	WORK=$TEST_ROOT/work
	OUTPUT=$TEST_ROOT/output
	mkdir -p $TEST_ROOT
	cat >$TEST_ROOT/test <<EOF
source ${0%/*}/tst-lib.sh
mkdir -p `readlink -f $WORK`
cd `readlink -f $WORK`
if [ -e "`readlink -f $TESTS/.setup`" ]; then
	source `readlink -f $TESTS/.setup`
fi
source `readlink -f $i`
RESULT=\$?
if [ -e "`readlink -f $TESTS/.teardown`" ]; then
	source `readlink -f $TESTS/.teardown`
fi
exit $RESULT
EOF
	chmod +x $TEST_ROOT/test
	if [ $VERBOSE ]; then
		run_test | tee $OUTPUT
	else
		run_test >$OUTPUT
	fi
	if [ "$RESULT" = 0 ]; then
		let success++
		if [ ! "$KEEP" ]; then
			rm -rf $TEST_ROOT
		fi
	else
		let failed++
		echo "[FAIL] $i"
		cat $OUTPUT
	fi
done

if [ $failed -gt 0 ]; then
	log "$failed of $total failed test(s)";
	exit 1
else 
	log "All $total tests were successful";
	if [ ! $KEEP ]; then
		rm -rf $TST_ROOT
	fi
	exit 0
fi
