mkdir tests
cd tests 
cat >always-passing.sh <<EOF
true
EOF

START=`date +%S`
echo First test creates results folder
tst -k
echo Second test creates results/older
tst -k
echo "Third test creates results/older/results-<date>.1"
tst -k
FINISH=`date +%S`
[ $START = $FINISH ] || die "This test must occur within the same second";

cd ..
[ `find * -maxdepth 0 -name 'results*' | wc -l` = 1 ] || die "Multiple results were created";
