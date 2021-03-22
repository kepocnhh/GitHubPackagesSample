echo "reject pr #$PR_NUMBER..."

if test -z "$github_pat"; then
  echo "GitHub personal access token must be exists!"
  return 1
fi

code=$(curl -w %{http_code} -o /dev/null -X PATCH \
  -s https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/pulls/$PR_NUMBER \
  -H "Authorization: token $github_pat" \
  -d '{"state":"closed"}')

if test $code -ne 200; then
  echo "Pull request #$PR_NUMBER rejecting error!"
  echo "Request error with response code $code!"
  return 2
fi

json="{\"body\":\"\
Closed by GitHub build \
[#$GITHUB_RUN_NUMBER](https://github.com/$GITHUB_OWNER/$GITHUB_REPO/actions/runs/$GITHUB_RUN_ID) \
that failed just because.\
\"}" # todo cause ?

code=$(curl -w %{http_code} -o /dev/null -X POST \
  -s https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/issues/$PR_NUMBER/comments \
  -H "Authorization: token $github_pat" \
  -d "$json")

if test $code -ne 201; then
  echo "Post comment to pr #$PR_NUMBER error!"
  echo "Request error with response code $code!"
  return 3
fi

echo "reject pr #$PR_NUMBER success"

return 0
