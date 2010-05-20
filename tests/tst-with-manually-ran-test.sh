mkdir tests
cat >tests/always-true.sh <<EOF
echo Output
true
EOF

tst -k
cd results/1/
[ -f test ] || die "test must be created";

./test || die "Test must actually work";

equals "Output" `./test` "Test outputs properly, without any redirection";
