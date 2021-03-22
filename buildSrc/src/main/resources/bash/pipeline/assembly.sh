echo "assembly start..."

ERROR_CODE_ARTIFACT_ID=11
ERROR_CODE_VERSION_NAME=1000
ERROR_CODE_ASSEMBLE=1100
ERROR_CODE_JAVADOC=1200
ERROR_CODE_SOURCES=1300
ERROR_CODE_POM=1400
CODE=0

ASSEMBLY_PATH="$ROOT_PATH/assembly"
rm -rf $ASSEMBLY_PATH
mkdir -p $ASSEMBLY_PATH

ARTIFACT_ID=$(gradle -q artifactId) || CODE=$?
if test $CODE -ne 0; then
  echo "assembly artifact id error $CODE!"
  exit $ERROR_CODE_ARTIFACT_ID
fi
echo "Artifact id \"$ARTIFACT_ID\""

SUMMARY="{"
ARRAY=($BUILD_TYPES)
SIZE=${#ARRAY[*]}
for ((i=0; i<SIZE; i++)); do
  ITEM=${ARRAY[i]}
  VERSION_NAME=$(gradle -q app:version${ITEM}Name) || CODE=$?
  if test $CODE -ne 0; then
    echo "version name $ITEM error $CODE!"
    exit $((ERROR_CODE_VERSION_NAME+i))
  fi
  echo "Version name $ITEM \"$VERSION_NAME\""
  [[ i -gt 0 ]] && SUMMARY="$SUMMARY,"
  SUMMARY="$SUMMARY\"$ITEM\":{"
  SUMMARY="$SUMMARY\"versionName\":\"$(echo "$VERSION_NAME" | base64)\""
  RESULT_PATH=$ASSEMBLY_PATH/build/$ITEM
  mkdir -p $RESULT_PATH
  # jar
  gradle -q clean app:assemble$ITEM || CODE=$?
  if test $CODE -ne 0; then
    echo "assembly $ITEM error!"
    exit $((ERROR_CODE_ASSEMBLE+i))
  fi
  FILE_NAME=${ARTIFACT_ID}-${VERSION_NAME}.jar
  mv app/build/libs/$FILE_NAME $RESULT_PATH
  SUMMARY="$SUMMARY,\"jar\":\"$(echo "$FILE_NAME" | base64)\""
  # javadoc
  gradle -q clean app:assemble${ITEM}Javadoc || CODE=$?
  if test $CODE -ne 0; then
    echo "assembly $ITEM javadoc error!"
    exit $((ERROR_CODE_JAVADOC+i))
  fi
  FILE_NAME=${ARTIFACT_ID}-${VERSION_NAME}-javadoc.jar
  mv app/build/libs/$FILE_NAME $RESULT_PATH
  SUMMARY="$SUMMARY,\"javadoc\":\"$(echo "$FILE_NAME" | base64)\""
  # sources
  gradle -q clean app:assemble${ITEM}Source || CODE=$?
  if test $CODE -ne 0; then
    echo "assembly $ITEM sources error!"
    exit $((ERROR_CODE_SOURCES+i))
  fi
  FILE_NAME=${ARTIFACT_ID}-${VERSION_NAME}-sources.jar
  mv app/build/libs/$FILE_NAME $RESULT_PATH
  SUMMARY="$SUMMARY,\"sources\":\"$(echo "$FILE_NAME" | base64)\""
  # pom
  gradle -q clean app:assemble${ITEM}Pom || CODE=$?
  if test $CODE -ne 0; then
    echo "assembly $ITEM pom error!"
    exit $((ERROR_CODE_POM+i))
  fi
  FILE_NAME=${ARTIFACT_ID}-${VERSION_NAME}.pom
  mv app/build/libs/$FILE_NAME $RESULT_PATH
  SUMMARY="$SUMMARY,\"pom\":\"$(echo "$FILE_NAME" | base64)\""
  #
  SUMMARY="$SUMMARY}"
done
SUMMARY="$SUMMARY}"

echo "$SUMMARY" > $ASSEMBLY_PATH/summary

echo "assembly success"

exit 0
