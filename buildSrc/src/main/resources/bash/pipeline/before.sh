#!/bin/bash

echo "before start..."

ERROR_CODE_COMPILE=11
CODE=0

gradle -q clean compileJava || CODE=$?
if test $CODE -ne 0; then
  echo "compile error!"
  exit $ERROR_CODE_COMPILE
fi

echo "before success"

exit 0
