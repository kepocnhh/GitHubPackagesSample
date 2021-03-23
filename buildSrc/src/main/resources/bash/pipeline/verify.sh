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
echo "verify test success"

ARRAY=(License Readme Service TestCoverage)
SIZE=${#ARRAY[*]}
for ((i=0; i<SIZE; i++)); do
 ITEM=${ARRAY[i]}
 gradle -q verify$ITEM || CODE=$?
 if test $CODE -ne 0; then
   echo "verify $ITEM error!"
   exit $((ERROR_CODE_VERIFY+i))
 fi
 echo "verify $ITEM success"
done

# todo code style
# todo documentations

echo "verify success"

exit 0
