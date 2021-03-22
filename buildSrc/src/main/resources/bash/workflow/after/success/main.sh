echo "after success..."

if test -z "$PR_NUMBER"; then
  echo "it is not pull request"
  return 0
fi

if test -z "$PR_SOURCE_BRANCH"; then
  echo "source branch of pull request #$PR_NUMBER undefined"
  return 1
fi

case "$PR_SOURCE_BRANCH" in
  dev|master) echo "It is a pull request to \"$PR_SOURCE_BRANCH\".";;
  *) 
  echo "Pull request to \"$PR_SOURCE_BRANCH\" no op"
  return 0;;
esac

exit 1
export TAG_NAME="$VERSION_NAME-snapshot" # todo dev/master
CODE=0
. $WORKFLOW/after/success/tag_test.sh || CODE=$?
if test $CODE -ne 0; then
  echo "after success tag test error $CODE!"
  return 21
fi
. $WORKFLOW/after/success/accept_pr.sh || CODE=$?
if test $CODE -ne 0; then
  echo "after success accept pr error $CODE!"
  return 22
fi
. $WORKFLOW/after/success/github_release.sh || CODE=$?
if test $CODE -ne 0; then
  echo "after success github release error $CODE!"
  return 23
fi

return 0
