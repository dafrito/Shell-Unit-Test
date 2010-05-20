#!/bin/bash
TST_PATH=${0%/*}
PATH=/bin:/usr/bin:$TST_PATH

TESTS=`readlink -f ./tests`
TESTS_ROOT=`readlink -f .`
RESULTS=./results

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
		echo "	$*"
	fi
}

while [ "$1" ]; do
	case "$1" in
		c|clean)	
			if [ -n "$RESULTS" ]; then
				rm -rf  $RESULTS
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

[ -d tests ] || error "no tests found";

if [ -e $RESULTS ]; then
	OLD_RESULTS=$RESULTS-`cat $RESULTS/timestamp`
	mv $RESULTS $OLD_RESULTS
	mkdir -p $RESULTS
	if [ -d $OLD_RESULTS/older ]; then
		mv $OLD_RESULTS/older $RESULTS
	else
		mkdir $RESULTS/older
	fi
	mv $OLD_RESULTS $RESULTS/older
fi
mkdir -p $RESULTS
touch $RESULTS/log
date +%Y.%m.%d-%H.%M.%S >$RESULTS/timestamp

function run_test {
	$TEST_ROOT/test
	RESULT=$?
}

for i in `find tests -type f ! -name '.*'`; do
	let total++
	log "$total. $i"
	TEST_ROOT=$RESULTS/$total
	mkdir -p $TEST_ROOT
	WORK=`readlink -f $TEST_ROOT`/work
	cat >$TEST_ROOT/test <<EOF
#!/bin/bash
PATH=/bin:/usr/bin:$TESTS_ROOT

source $TST_PATH/library.sh
if [ -e "$WORK" ]; then
	mv "$WORK" "$WORK".\`find * -maxdepth 0 -name '$WORK*' | wc -l\`
fi
mkdir -p "$WORK"
cd "$WORK"
if [ -e "$TESTS/.setup" ]; then
	source $TESTS/.setup
fi
source `readlink -f $i`
RESULT=\$?
if [ -e "$TESTS/.teardown" ]; then
	source $TESTS/.teardown
fi

exit $RESULT
EOF
	chmod +x $TEST_ROOT/test
	run_test 2>$TEST_ROOT/err 1>$TEST_ROOT/out
	if [ "$RESULT" = 0 ] && [ ! -s $TEST_ROOT/err ]; then
		let success++
	else
		RESULT=1
		let failed++
	fi
	if [ "$RESULT" != 0 ]; then
		echo "$total. ${i#*/} failed" 1>&2
	fi
	if [ -s $TEST_ROOT/err ]; then
		cat $TEST_ROOT/err | sed "s/^/	/g";
	fi
	if [ "$VERBOSE" ]; then
		cat $TEST_ROOT/out | set "s/^/	/g";
	fi
	if [ "$RESULT" = 0 ] && [ ! "$KEEP" ]; then
		rm -rf $TEST_ROOT
	fi
done

if [ $failed -gt 0 ]; then
	error "$failed of $total test(s) failed";
else 
	log "All $total tests were successful";
	if [ ! $KEEP ] && [ ! -e "$RESULTS/older" ]; then
		rm -rf $RESULTS
	fi
	exit 0
fi
