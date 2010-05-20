mkdir tests
cat >tests/test.sh <<EOF
false
EOF

tst 2>&1
[ ! -e results/older ] || "older directory must not be spuriously created";
tst 2>&1
[ -d results/older ] || die "older directory must be created for subsequent runs";
