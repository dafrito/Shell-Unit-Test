#!/bin/bash
if [ ! "$TST_EXECUTABLE_DIR" ]; then
	TST_EXECUTABLE_DIR=${0%/*}
fi
source "$TST_EXECUTABLE_DIR/library.sh" || exit 1
PATH=/bin:/usr/bin

RESULTS=./results

while [ "$1" ]; do
	case "$1" in
		g|goto)	
			while [ ! -d "tests" ]; do
				if [ `pwd` = "/" ]; then
					exit 1
				fi
				cd ..
			done
			pwd
			exit
			;;
		c|clean)	
			if [ -n "$RESULTS" ]; then
				rm -rf  $RESULTS
			fi
			exit
			;;
		-k)	KEEP=true ;;
		-v)	VERBOSE=true ;;
		-*) error "Unsupported option: $1" ;;
	esac
	shift
done

if [ ! -d tests ]; then
	if [ -d ../tests ]; then
		# It's common that we're working in ./tests, so we support this one case.
		cd ..
	else
		error "no tests found";
	fi
fi
TESTS_ROOT=`pwd`
TESTS=`pwd`/tests

if [ -e $RESULTS ]; then
	OLD=$RESULTS-`cat $RESULTS/timestamp`
	mv $RESULTS $OLD
	mkdir -p $RESULTS
	if [ -d $OLD/older ]; then
		mv $OLD/older $RESULTS
	else
		mkdir $RESULTS/older
	fi
	mv $OLD $RESULTS/older
fi

mkdir -p $RESULTS
touch $RESULTS/log
date +%Y.%m.%d-%H.%M.%S >$RESULTS/timestamp

total=0
success=0
failed=0
for current_test in `find tests -type f ! -name '.*'`; do
	let total++
	log "$total. $current_test"
	mkdir -p $RESULTS/$total
	pushd $RESULTS/$total >/dev/null
	cat >run <<EOF
#!/bin/bash
TST_EXECUTABLE_DIR="$TST_EXECUTABLE_DIR"
\$TST_EXECUTABLE_DIR/run-one-test.sh "$TESTS_ROOT/$current_test"
EOF
	chmod +x run
	./run 2>err 1>out
	R=$?
	if [ "$R" = 0 ] && [ ! -s err ]; then
		let success++
	else
		if [ ! "$R" ]; then
			R=1;
		fi
		let failed++
	fi
	if [ "$R" != 0 ]; then
		echo "$total. ${current_test#*/} failed" 1>&2
	fi
	if [ -s err ]; then
		cat err | sed "s/^/	/g";
	fi
	if [ "$VERBOSE" ]; then
		cat out | set "s/^/	/g";
	fi
	popd >/dev/null
	if [ "$R" = 0 ] && [ ! "$KEEP" ]; then
		rm -rf $RESULTS/$total
	fi
done

if [ $failed -gt 0 ]; then
	error "$failed of $total test(s) failed";
else 
	log "All $total tests were successful";
	if [ ! "$KEEP" ] && [ ! -e "$RESULTS/older" ]; then
		rm -rf $RESULTS
	fi
	exit 0
fi
