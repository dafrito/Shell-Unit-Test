mkdir tests
cd tests
cat >equals-test.sh <<EOF
equals "A" "A"
EOF
tst || die "equals must succeed for equal values";

cat >equals-test.sh <<EOF
equals "A" "B"
EOF
expect tst || die "equals must fail for equal values"

cat >equals-test.sh <<EOF
equals "A B" "A B"
EOF
tst || die "equals must pass for equal values, even when separated by IFS"

cat >equals-test.sh <<EOF
equals "A B" A B
EOF
tst || die "equals must pass for equal values, even when not quoted"
