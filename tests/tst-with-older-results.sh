mkdir tests
cat >tests/always-passing.sh <<EOF
true
EOF

tst
[ ! -e results ] || die "tst must not preserve passing test results";

tst -k
[ -e results ] || die "tst must, if asked, preserve passing test results";

tst
[ -e results ] || die "tst must preserve existing test results if it finds them";
