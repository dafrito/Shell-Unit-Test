mkdir tests
cat >tests/test.sh <<EOF
	false
EOF
! tst 2>&1 || die "tst must fail when a test fails";
