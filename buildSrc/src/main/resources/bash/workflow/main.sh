#!/bin/bash

echo "main start..."

ERROR_CODE_VCS=21
ERROR_CODE_SETUP=22
ERROR_CODE_BUILD=31
CODE=0

export WORKFLOW=$RESOURCES_PATH/bash/workflow

. $WORKFLOW/vcs.sh
CODE=$?
if test $CODE -ne 0; then
 echo "Version control system error $CODE!"
 exit $ERROR_CODE_VCS
fi

. $WORKFLOW/setup.sh
CODE=$?
if test $CODE -ne 0; then
 echo "Setup error $CODE!"
 exit $ERROR_CODE_SETUP
fi

if test "$IS_LIGHTWEIGHT_BUILD_INTERNAL" == $TRUE; then
 echo "skip main pipeline..."
else
 . $WORKFLOW/build/main.sh || IS_BUILD_SUCCESS=$FALSE

 if test $IS_BUILD_SUCCESS == $TRUE; then
  . $WORKFLOW/after/success/main.sh || IS_BUILD_SUCCESS=$FALSE
 fi
 if test $IS_BUILD_SUCCESS != $TRUE; then
  . $WORKFLOW/after/failure/main.sh
 fi
fi

. $WORKFLOW/after/common.sh

if test "$IS_BUILD_SUCCESS" != $TRUE; then
 exit $ERROR_CODE_BUILD
fi

echo "main success"

exit 0
