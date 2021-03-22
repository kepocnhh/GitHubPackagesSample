#!/bin/bash

echo "accept pr #$PR_NUMBER start..."

if test -z $github_pat; then
    echo "GitHub personal access token must be exists!"
    return 1
fi

title="Merge ${GIT_COMMIT_SHA::7} -> $PR_SOURCE_BRANCH by $GIT_WORKER_NAME"
message="service commit" # todo
json="{\
\"commit_title\":\"$title\",\
\"commit_message\":\"$message\"\
}"

code=$(curl -w %{http_code} -o /dev/null -X PUT \
    -s https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/pulls/$PR_NUMBER/merge \
    -H "Authorization: token $github_pat" \
    -d "$json")

if test $code -ne 200; then
    echo "Pull request #$PR_NUMBER accepting error!"
    echo "Request error with response code $code!"
    return 2
fi

REPO_URL=https://github.com/$GITHUB_OWNER/$GITHUB_REPO

json="{\"body\":\"\
Successfully accepted by GitHub build \
[#$GITHUB_RUN_NUMBER](https://github.com/$GITHUB_OWNER/$GITHUB_REPO/actions/runs/$GITHUB_RUN_ID) \
\"}"

code=$(curl -w %{http_code} -o /dev/null -X POST \
    -s https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/issues/$PR_NUMBER/comments \
    -H "Authorization: token $github_pat" \
    -d "$json")

if test $code -ne 201; then
    echo "Post comment to pr #$PR_NUMBER error!"
    echo "Request error with response code $code!"
    return 3
fi

echo "accept pr #$PR_NUMBER success"

return 0
