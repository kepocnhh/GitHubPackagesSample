#!/bin/bash

echo "maven deploy start..."

ERROR_CODE_SONATYPE_USERNAME=11
ERROR_CODE_SONATYPE_PASSWORD=12
ERROR_CODE_PR_SOURCE_BRANCH=21
ERROR_CODE_UPLOAD=100
CODE=0

if test -z "$sonatype_username"; then
    echo "Sonatype username empty!"
    return $ERROR_CODE_SONATYPE_USERNAME
fi
if test -z "$sonatype_password"; then
    echo "Sonatype password empty!"
    return $ERROR_CODE_SONATYPE_PASSWORD
fi

URL_BASE=https://s01.oss.sonatype.org
URL=""
FILE_TYPES=""
case "$PR_SOURCE_BRANCH" in
  dev)
   URL=$URL_BASE/content/repositories/snapshots
   FILE_TYPES="file checksum"
  ;;
  master)
   return 1 # todo not now
   URL=$URL_BASE/service/local/staging/deploy/maven2
   FILE_TYPES="file checksum signature"
  ;;
  *)
   echo "Pull request to \"$PR_SOURCE_BRANCH\" is not supported!"
   return $ERROR_CODE_PR_SOURCE_BRANCH;;
esac

GROUP_ID_URL=${MAVEN_GROUP_ID//'.'/'/'}
TMP_PATH=/tmp/maven/deploy/$GROUP_ID_URL/$MAVEN_ARTIFACT_ID
rm -rf $TMP_PATH
mkdir -p $TMP_PATH

# echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
# <metadata>
#  <groupId>$MAVEN_GROUP_ID</groupId>
#  <artifactId>$MAVEN_ARTIFACT_ID</artifactId>
#  <versioning>
#   <release>$TAG_NAME</release>
#   <versions>
#    <version>$TAG_NAME</version>
#   </versions>
#   <lastUpdated>$(date +%Y%m%d%H%M%S)</lastUpdated>
#  </versioning>
# </metadata>" > $TMP_PATH/maven-metadata.xml
# todo maven metadata

ARRAY=(jar javadoc sources pom)
SIZE=${#ARRAY[*]}
for ((i=0; i<SIZE; i++)); do
 ITEM=${ARRAY[i]}
 FILE_NAME=$(cat $ASSEMBLY_PATH/summary | jq -r .${BUILD_TYPE}.${ITEM} | base64 -d)
 echo "upload $ITEM start..."
 for type in $FILE_TYPES; do
  DATA=$ASSEMBLY_PATH/build/$BUILD_TYPE/$FILE_NAME
  case "$type" in
   file)
    F=$FILENAME;;
   checksum)
    F=${FILENAME}.md5
    D=${DATA}.md5
    md5 -q $DATA > $D;;
   signature)
    F=${FILENAME}.asc
    D=${DATA}.asc
    return 1 # todo
    gpg -ab $DATA;;
  esac
  CODE=$(curl -X POST -s $URL/$GROUP_ID_URL/$MAVEN_ARTIFACT_ID/$TAG_NAME/$F \
   -w %{http_code} \
   -u $sonatype_username:$sonatype_password \
   -H 'Content-Type: text/plain' \
   -H "User-Agent: $MAVEN_GROUP_ID:$MAVEN_ARTIFACT_ID" \
   --data-binary "@$D")
  echo "upload $F success"
 done
 echo "upload $ITEM success"
done

echo "maven deploy success"

return 0
