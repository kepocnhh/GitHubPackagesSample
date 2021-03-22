echo "after common start..."

REPO_OWNER=$GITHUB_OWNER
REPO_NAME=$GITHUB_REPO
REPO_URL=https://github.com/$REPO_OWNER/$REPO_NAME

TOP="GitHub build [#$GITHUB_RUN_NUMBER]($REPO_URL/actions/runs/$GITHUB_RUN_ID)"
BOT=""

if test "$IS_LIGHTWEIGHT_BUILD_INTERNAL" == $TRUE; then
  TOP="$TOP skipped"
else
  if test $IS_BUILD_SUCCESS == $TRUE; then
    if [[ $PR_NUMBER =~ $IS_INTEGER_REGEX ]]; then
      rm -f file
      code=$(curl -w %{http_code} -o file \
        -s https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/pulls/$PR_NUMBER)
      if test $code -ne 200; then
        echo "Get pull request #$PR_NUMBER error!"
        echo "Request error with response code $code!"
        return 1
      fi
      body=$(<file)
      rm file
      merged=$(echo $body | jq -r .merged)
      if test $merged == true; then
        BOT="

pull request [#$PR_NUMBER](https://github.com/$GITHUB_OWNER/$GITHUB_REPO/pull/$PR_NUMBER) \
merged by [$GIT_WORKER_NAME](https://github.com/$GITHUB_WORKER_LOGIN)"
      else
        echo "Pull request #$PR_NUMBER not merged"
      fi
    fi
  else
    TOP="$TOP failed!"
    if [[ $PR_NUMBER =~ $IS_INTEGER_REGEX ]]; then
      rm -f file
      code=$(curl -w %{http_code} -o file \
        -s https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/pulls/$PR_NUMBER)
      if test $code -ne 200; then
        echo "Get pull request #$PR_NUMBER error!"
        echo "Request error with response code $code!"
        return 1
      fi
      body=$(<file)
      rm file
      merged=$(echo $body | jq -r .merged)
      if test $merged == true; then
        echo "Pull request #$PR_NUMBER merged"
      else
        issueUrl=$(echo $body | jq -r ._links.issue.href)
        code=$(curl -w %{http_code} -o file -s $issueUrl)
        if test $code -ne 200; then
          echo "Get issue #$PR_NUMBER error!"
          echo "Request error with response code $code!"
          return 2
        fi
        body=$(<file)
        rm file
        closedBy=$(echo $body | jq -r .closed_by.login)
        if test "$closedBy" == $GITHUB_WORKER_LOGIN; then
          BOT="

pull request [#$PR_NUMBER](https://github.com/$GITHUB_OWNER/$GITHUB_REPO/pull/$PR_NUMBER) \
closed by [$GIT_WORKER_NAME](https://github.com/$GITHUB_WORKER_LOGIN)"
        else
          echo "Issue #$PR_NUMBER was not closed by \"$GITHUB_WORKER_LOGIN\""
        fi
      fi
    fi
  fi
fi

user=""
if test -z "$GITHUB_AUTHOR_LOGIN"; then
  if test -z "$GIT_AUTHOR_NAME"; then
    if test -z "$GIT_AUTHOR_EMAIL"; then
      if test -z "$GITHUB_COMMITTER_LOGIN"; then
        if test -z "$GIT_COMMITTER_NAME"; then
          if test -z "$GIT_COMMITTER_EMAIL"; then
            echo "No responsible user!"
            return 2
          else
            user="$GIT_COMMITTER_EMAIL"
          fi
        else
          user="$GIT_COMMITTER_NAME"
        fi
      else
        if test -z "$GIT_COMMITTER_NAME"; then
          user="[$GITHUB_COMMITTER_LOGIN](https://github.com/$GITHUB_COMMITTER_LOGIN)"
        else
          user="[$GIT_COMMITTER_NAME](https://github.com/$GITHUB_COMMITTER_LOGIN)"
        fi
      fi
    else
      user="$GIT_AUTHOR_EMAIL"
    fi
  else
    user="$GIT_AUTHOR_NAME"
  fi
else
  if test -z "$GIT_AUTHOR_NAME"; then
    user="[$GITHUB_AUTHOR_LOGIN](https://github.com/$GITHUB_AUTHOR_LOGIN)"
  else
    user="[$GIT_AUTHOR_NAME](https://github.com/$GITHUB_AUTHOR_LOGIN)"
  fi
fi

MESSAGE="$TOP

[$REPO_OWNER](https://github.com/$REPO_OWNER) / [$REPO_NAME]($REPO_URL)

[${GIT_COMMIT_SHA::7}]($REPO_URL/commit/$GIT_COMMIT_SHA) by $user$BOT"

/bin/bash $WORKFLOW/telegram_send_message.sh "$MESSAGE"

echo "after common success"

return 0
