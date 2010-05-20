! tst 2>&1 || die "tst must fail if no tests exist"

[ ! -e  "results" ] || die "tst must not create results if no tests were found";
