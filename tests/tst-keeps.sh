mkdir tests
cat >tests/always-passing.sh <<EOF
true
EOF

tst -k
[ -e results ] || die "tst must respect -k and keep tests";
[ -e results/1-always-passing ] || die "tst must respect -k and keep even passing tests";
