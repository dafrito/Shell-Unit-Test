#!/bin/bash
TST_PATH=${0%/*}
PATH=/bin:/usr/bin:$TST_PATH

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
		-*)
			error "Unsupported option: $1"
	esac
	shift
done

total=0
success=0
failed=0

if [ ! -d tests ]; then
	if [ -d ../tests ]; then
		# It's common that we're working in ./tests, so we support this one case.
		cd ..
	else
		error "no tests found";
	fi
fi
TESTS=`readlink -f ./tests`
TESTS_ROOT=`readlink -f .`
RESULTS=./results

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

for i in `find tests -type f ! -name '.*'`; do
	let total++
	log "$total. $i"
	mkdir -p $RESULTS/$total
	pushd $RESULTS/$total >/dev/null
	cat >test <<EOF
#!/bin/bash
PATH=/bin:/usr/bin:$TESTS_ROOT
source $TST_PATH/library.sh

if [ -e work ]; then
	mv work work-\`find * -maxdepth 0 -name 'work*' | wc -l\`
fi
mkdir -p work
cd work

ROOT=$TESTS
[ -e "\$ROOT/.setup" ] && source \$ROOT/.setup
source \$ROOT/../$i
RESULT=\$?
[ -e "\$ROOT/.teardown" ] && source \$ROOT/.teardown

exit \$RESULT
EOF
	chmod +x test
	./test 2>err 1>out
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
		echo "$total. ${i#*/} failed" 1>&2
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
	if [ ! $KEEP ] && [ ! -e "$RESULTS/older" ]; then
		rm -rf $RESULTS
	fi
	exit 0
fi
