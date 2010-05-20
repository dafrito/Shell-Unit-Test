! tst || die "tst must fail if no tests exist"

mkdir tests
tst || die "tst must pass if no tests are given"

cat >tests/test.sh <<EOF
	true
EOF
tst || die "tst must pass when all tests pass";

cat >tests/test.sh <<EOF
	false
EOF
! tst || die "tst must fail when a test fails";
