mkdir tests
cat >tests/test.sh <<EOF
false
EOF

tst
[ ! -e results/older ] || "older directory must not be spuriously created";
tst
[ -d results/older ] || die "older directory must be created for subsequent runs";
