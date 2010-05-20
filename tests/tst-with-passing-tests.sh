mkdir tests
cat >tests/test.sh <<EOF
	true
EOF
tst || die "tst must pass when all tests pass";

