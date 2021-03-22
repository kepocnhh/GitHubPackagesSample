echo "after failure..."

if test -z "$PR_NUMBER"; then
 echo "it is not a pull request"
 return 0
fi

if test -z "$PR_SOURCE_BRANCH"; then
 echo "source branch of pull request #$PR_NUMBER undefined"
 return 1
fi

case "$PR_SOURCE_BRANCH" in
 dev|master)
  . $WORKFLOW/after/failure/reject_pr.sh || return 2;;
 *) echo "$PR_SOURCE_BRANCH is not in [dev, master]";;
esac

return 0
