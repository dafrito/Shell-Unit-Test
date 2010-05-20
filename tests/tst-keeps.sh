mkdir tests
cat >always-passing.sh <<EOF
true
EOF

tst -k
[ -e results ] || die "tst must respect -k and keep tests";
