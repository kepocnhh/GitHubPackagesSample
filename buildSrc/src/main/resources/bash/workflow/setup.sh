echo "setup..."

if test -z "$GIT_COMMIT_MESSAGE"; then
  echo "Git commit message must be exists!"
  return 11
fi

export IS_INTEGER_REGEX="^[1-9][0-9]*$"

export TRUE=true
export FALSE=false
export AUTO=auto

export IS_BUILD_SUCCESS=$TRUE

export IS_LIGHTWEIGHT_BUILD=$TRUE
export IS_LIGHTWEIGHT_BUILD_INTERNAL=$TRUE

if [[ $PR_NUMBER =~ $IS_INTEGER_REGEX ]]; then
  if test -z "$PR_SOURCE_BRANCH"; then
    echo "name of the branch from which the PR originated must be not empty"
    return 21
  fi
  case "$PR_SOURCE_BRANCH" in
  dev)
    ARRAY=(dev )
    SIZE=${#ARRAY[*]}
    for ((i = 0; i < SIZE; i++)); do
      BRANCH_NAME=${ARRAY[$i]}
      if test "$BRANCH_NAME" == $GIT_SOURCE_BRANCH; then
        echo "Pull request to \"$PR_SOURCE_BRANCH\" forbidden for \"$GIT_SOURCE_BRANCH\"!"
        return $((100 + i))
      fi
    done
    export BUILD_TYPE="snapshot";;
  master)
    if test dev != $GIT_SOURCE_BRANCH; then
      echo "Pull request to \"$PR_SOURCE_BRANCH\" forbidden for \"$GIT_SOURCE_BRANCH\"!"
      return 23
    fi
    export BUILD_TYPE="release";;
  esac
  echo "It is a pull request #$PR_NUMBER $GIT_SOURCE_BRANCH -> $PR_SOURCE_BRANCH"
else
  echo "It is not a pull request."
fi

if [[ $GIT_COMMIT_MESSAGE == *"forceci"* ]]; then
  IS_LIGHTWEIGHT_BUILD=$FALSE
  echo "Commit message contains keyword."
elif [[ $PR_NUMBER =~ $IS_INTEGER_REGEX ]]; then
  case "$PR_SOURCE_BRANCH" in
    dev|master)
      IS_LIGHTWEIGHT_BUILD=$FALSE
      echo "It is a pull request to $PR_SOURCE_BRANCH.";;
    *) echo "It is a pull request but not to one of [dev, master]";;
  esac
fi

case "$CI_BUILD_LIGHTWEIGHT" in
"$TRUE") echo "It is lightweight build because CI_BUILD_LIGHTWEIGHT == true" ;;
"$FALSE")
  IS_LIGHTWEIGHT_BUILD_INTERNAL=$FALSE
  echo "It is not a lightweight build because CI_BUILD_LIGHTWEIGHT == false"
  ;;
"$AUTO")
  case "$IS_LIGHTWEIGHT_BUILD" in
  "$TRUE") echo "It is lightweight build because IS_LIGHTWEIGHT_BUILD == true" ;;
  "$FALSE")
    IS_LIGHTWEIGHT_BUILD_INTERNAL=$FALSE
    echo "It is not a lightweight build because IS_LIGHTWEIGHT_BUILD == false"
    ;;
  *)
    echo "IS_LIGHTWEIGHT_BUILD must be in [$TRUE, $FALSE], but it is \"$IS_LIGHTWEIGHT_BUILD\"!"
    return 32
    ;;
  esac
  ;;
*)
  echo "CI_BUILD_LIGHTWEIGHT must be in [$TRUE, $FALSE, $AUTO], but it is \"$CI_BUILD_LIGHTWEIGHT\"!"
  return 31
  ;;
esac

echo "setup success"

return 0
