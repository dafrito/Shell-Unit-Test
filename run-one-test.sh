#!/bin/bash
if [ ! "$TST_EXECUTABLE_DIR" ]; then
	TST_EXECUTABLE_DIR=${0%/*}
fi
source $TST_EXECUTABLE_DIR/test-library.sh || exit 1
PATH=/bin:/usr/bin 

TEST_NAME=$*
if [ ! -f "$TEST_NAME" ]; then
	die "'$TEST_NAME' does not exist or is not a file";
fi 
PROJECT_ROOT=${TEST_NAME%tests/*}

if [ -e work ]; then
	mv work work-`find * -maxdepth 0 -name 'work*' | wc -l`
fi
mkdir -p work
cd work

PATH=/bin:/usr/bin:$PROJECT_ROOT

[ -e "$PROJECT_ROOT/tests/.setup" ] && source "$PROJECT_ROOT/tests/.setup"

source "$TEST_NAME"
RESULT=$?

[ -e "$PROJECT_ROOT/tests/.teardown" ] && source "$PROJECT_ROOT/tests/.teardown"

exit $RESULT
