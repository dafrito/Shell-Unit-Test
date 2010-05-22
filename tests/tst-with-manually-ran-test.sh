mkdir tests
cat >tests/always-true.sh <<EOF
echo Output
true
EOF

tst -k
cd results/1-always-true/
[ -f run ] || die "test must be created";

./run || die "Test must actually work";

equals "Output" `./run` || die "Test outputs properly, without any redirection";
