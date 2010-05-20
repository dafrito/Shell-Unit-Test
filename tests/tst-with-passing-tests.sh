mkdir tests
cat >tests/always-passing.sh <<EOF
	true
EOF
tst || die "tst must pass when all tests pass";
