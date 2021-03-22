echo "assembly start..."

ERROR_CODE_ARTIFACT_ID=11
ERROR_CODE_VERSION_NAME=1000
ERROR_CODE_ASSEMBLE=1100
CODE=0

ASSEMBLY_PATH=/assembly
rm -rf $ASSEMBLY_PATH
mkdir -p $ASSEMBLY_PATH

ARTIFACT_ID=$(gradle -q artifactId) || CODE=$?
if test $CODE -ne 0; then
  echo "assembly artifact id error $CODE!"
  exit $ERROR_CODE_ARTIFACT_ID
fi
echo "Artifact id $ARTIFACT_ID"

SUMMARY="{"
SUMMARY="$SUMMARY\"artifactId\":\"$(echo "$ARTIFACT_ID" | base64)\""

ARRAY=($BUILD_TYPE)
SIZE=${#ARRAY[*]}
SUMMARY="$SUMMARY,\"buildTypes\":{"
for ((i=0; i<SIZE; i++)); do
  ITEM=${ARRAY[i]}
  VERSION_NAME=$(gradle -q app:version${ITEM}Name) || CODE=$?
  if test $CODE -ne 0; then
    echo "version name $ITEM error $CODE!"
    exit $((ERROR_CODE_VERSION_NAME+i))
  fi
  [[ i -gt 0 ]] && SUMMARY="$SUMMARY,"
  SUMMARY="$SUMMARY\"$ITEM\":{"
  SUMMARY="$SUMMARY\"versionName\":\"$(echo "$VERSION_NAME" | base64)\""
  echo "Version name $ITEM $VERSION_NAME"
  gradle -q clean app:assemble$ITEM || CODE=$?
  if test $CODE -ne 0; then
    echo "assembly $ITEM error!"
    exit $((ERROR_CODE_ASSEMBLE+i))
  fi
  FILE_NAME=${ARTIFACT_ID}-${VERSION_NAME}.jar
  RESULT_PATH=$ASSEMBLY_PATH/build/$ITEM
  mkdir -p $RESULT_PATH
  mv app/libs/$FILE_NAME $RESULT_PATH
  SUMMARY="$SUMMARY,\"jar\":\"$(echo "$FILE_NAME" | base64)\""
  # todo javadoc
  # todo sources
  # todo pom
  exit 1
  SUMMARY="$SUMMARY}"
done
SUMMARY="$SUMMARY}"

SUMMARY="$SUMMARY}"
echo "$SUMMARY" > $ASSEMBLY_PATH/summary

echo "assembly success"

exit 0
