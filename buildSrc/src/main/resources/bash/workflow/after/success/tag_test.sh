#!/bin/bash

echo "tag test start..."

REF=refs/tags/$TAG_NAME

rm -f file
code=$(curl -w %{http_code} -o file \
  -s https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/git/$REF)
if test $code -eq 404; then
  echo "Tag $TAG_NAME doesn't exist yet."
  return 0
elif test $code -ne 200; then
  echo "Request error with response code $code!"
  return 1
fi
BODY=$(<file)
rm file

TMP=$(echo "$BODY" | jq -r .ref)
if test "$TMP" == $REF; then
  echo "Tag $TAG_NAME already exists!"
  return 21
fi

ARRAY=($(echo "$BODY" | jq -r .[].ref))
SIZE=${#ARRAY[*]}
for ((i = 0; i < SIZE; i++)); do
  TMP=${ARRAY[$i]}
  if test "$TMP" == $REF; then
    echo "Tag $TAG_NAME already exists!"
    return $((100 + i))
  fi
done

echo "Tag $TAG_NAME doesn't exist yet."

return 0
