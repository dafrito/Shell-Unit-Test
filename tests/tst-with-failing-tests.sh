mkdir tests
cat >tests/always-failing.sh <<EOF
	false
EOF
! tst 2>&1 || die "tst must fail when a test fails";
