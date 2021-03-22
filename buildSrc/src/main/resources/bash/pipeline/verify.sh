#!/bin/bash

echo "verify start..."

ERROR_CODE_TEST=11
ERROR_CODE_VERIFY=100
CODE=0

gradle -q clean app:test || CODE=$?
if test $CODE -ne 0; then
  echo "verify test error!"
  exit $ERROR_CODE_TEST
fi

ARRAY=(License Readme Service)
SIZE=${#ARRAY[*]}
for ((i=0; i<SIZE; i++)); do
 ITEM=${ARRAY[i]}
 gradle -q verify$ITEM || CODE=$?
 if test $CODE -ne 0; then
   echo "verify $ITEM error!"
   exit $((ERROR_CODE_VERIFY+i))
 fi
done

# todo documentation
# todo test coverage

echo "verify success"

exit 0
