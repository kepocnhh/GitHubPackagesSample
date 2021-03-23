#!/bin/bash

echo "after success start..."

if test -z "$PR_NUMBER"; then
  echo "it is not pull request"
  return 0
fi

if test -z "$PR_SOURCE_BRANCH"; then
  echo "source branch of pull request #$PR_NUMBER undefined"
  return 11
fi

case "$PR_SOURCE_BRANCH" in
  dev|master) echo "It is a pull request to \"$PR_SOURCE_BRANCH\".";;
  *)
   echo "Pull request to \"$PR_SOURCE_BRANCH\" no op"
   return 0;;
esac
VERSION_NAME=$(cat $ASSEMBLY_PATH/summary | jq -r .${BUILD_TYPE}.versionName | base64 -d)
if [[ -z "$VERSION_NAME" ]]; then
 echo "Version name pull request to \"$PR_SOURCE_BRANCH\" error!"
 return 31
fi

export TAG_NAME="$VERSION_NAME"
CODE=0

. $WORKFLOW/after/success/tag_test.sh; CODE=$?
if test $CODE -ne 0; then
  echo "after success tag test error $CODE!"
  return 21
fi

. $WORKFLOW/after/success/github_deploy.sh; CODE=$?
if test $CODE -ne 0; then
  echo "after success github deploy error $CODE!"
  return 23
fi

. $WORKFLOW/after/success/maven_deploy.sh; CODE=$?
if test $CODE -ne 0; then
  echo "after success maven deploy error $CODE!"
  return 24
fi

. $WORKFLOW/after/success/accept_pr.sh; CODE=$?
if test $CODE -ne 0; then
  echo "after success accept pr error $CODE!"
  return 22
fi

return 0
