mkdir tests
cd tests 
cat >always-passing.sh <<EOF
true
EOF

CHOKE=0
while true; do
	[ $CHOKE -lt 10 ] || die "Test would not complete in 10 tries";
	START=`date +%S`
	echo First test creates results folder
	tst -k
	echo Second test creates results/older
	tst -k
	echo "Third test creates results/older/results-<date>.1"
	tst -k
	FINISH=`date +%S`
	if [ $START = $FINISH ]; then
		break;
	else
		tst c
	fi
	let CHOKE++
done

cd ..
[ `find * -maxdepth 0 -name 'results*' | wc -l` = 1 ] || die "Multiple results were created";
