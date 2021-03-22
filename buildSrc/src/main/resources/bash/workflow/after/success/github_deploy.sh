#!/bin/bash

echo "github deploy start..."

ERROR_CODE_UPLOAD=100

if test -z $github_pat; then
    echo "GitHub personal access token must be exists!"
    return 11
fi

PRERELESE=true
case "$PR_SOURCE_BRANCH" in
  dev)
   PRERELESE=true
  ;;
  master)
   PRERELESE=false
  ;;
  *)
   echo "Pull request to \"$PR_SOURCE_BRANCH\" is not supported!"
   return 41;;
esac

body="by $GIT_WORKER_NAME"
json="{\
\"tag_name\":\"$TAG_NAME\",
\"target_commitish\":\"$GIT_COMMIT_SHA\",
\"name\":\"$TAG_NAME\",
\"body\":\"$body\",
\"draft\":false,
\"prerelease\":$PRERELESE
}"

rm -f file
code=$(curl -w %{http_code} -o file -X POST \
    -s https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases \
    -H "Authorization: token $github_pat" \
    -d "$json")
if test $code -ne 201; then
    echo "Create $TAG_NAME release error!"
    echo "Request error with response code $code!"
    return 21
fi
body=$(<file); rm file

releaseId=$(echo $body | jq -r .id)

ARRAY=(jar javadoc sources pom)
SIZE=${#ARRAY[*]}
for ((i=0; i<SIZE; i++)); do
 ITEM=${ARRAY[i]}
 FILE_NAME=$(cat $ASSEMBLY_PATH/summary | jq -r .${BUILD_TYPE}.${ITEM} | base64 -d)
 CODE=$(curl -w %{http_code} -o /dev/null -X POST \
  -s "https://uploads.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases/$releaseId/assets?name=$FILE_NAME&label=$FILE_NAME" \
  -H "Content-Type: text/plain" \
  -H "Authorization: token $github_pat" \
  --data-binary @$ASSEMBLY_PATH/build/$BUILD_TYPE/$FILE_NAME)
 if test $CODE -ne 0; then
   echo "upload $ITEM error!"
   echo "Request error with response code $CODE!"
   exit $((ERROR_CODE_UPLOAD+i))
 fi
done

echo "github deploy success"

return 0
