mkdir tests
cat >tests/always-passes.sh <<EOF
true
EOF

tst -k
[ -e results ] || die "tst -k must keep passing results";
tst c
[ ! -e results ] || die "tst c must remove any results";

tst -k
tst -k
[ -e results/older ] || die "tst must create older arguments on multiple results";
tst c
[ ! -e results ] || die "tst c must remove results, even if there are multiple results";
