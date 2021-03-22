#!/bin/bash

echo "pipeline start..."

ERROR_CODE_BEFORE=11
ERROR_CODE_VERIFY=31
ERROR_CODE_ASSEMBLY=91
CODE=0

export ROOT_PATH=""
export PIPELINE=buildSrc/src/main/resources/bash/pipeline

/bin/bash $PIPELINE/before.sh || CODE=$?
if test $CODE -ne 0; then
  echo "Pipeline before error $CODE!"
  exit $ERROR_CODE_BEFORE
fi

/bin/bash $PIPELINE/verify.sh || CODE=$?
if test $CODE -ne 0; then
  echo "Pipeline verify error $CODE!"
  exit $ERROR_CODE_VERIFY
fi

# todo documentation

/bin/bash $PIPELINE/assembly.sh || CODE=$?
if test $CODE -ne 0; then
  echo "Pipeline assembly error $CODE!"
  exit $ERROR_CODE_ASSEMBLY
fi

echo "pipeline success"

exit 0
