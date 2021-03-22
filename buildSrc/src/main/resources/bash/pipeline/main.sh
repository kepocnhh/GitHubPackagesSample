#!/bin/bash

echo "pipeline start..."

ERROR_CODE_BEFORE=11
ERROR_CODE_ASSEMBLY=21
CODE=0

export PIPELINE=buildSrc/src/main/resources/bash/pipeline

# todo before
# todo testing
# todo verify
# todo documentation

/bin/bash $PIPELINE/assembly.sh || CODE=$?
if test $CODE -ne 0; then
  echo "Pipeline assembly error $CODE!"
  exit $ERROR_CODE_ASSEMBLY
fi

echo "pipeline success"

exit 0
