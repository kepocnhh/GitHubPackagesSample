echo "assembly start..."

ARRAY=(
  "docker run --name $DOCKER_CONTAINER_NAME $DOCKER_IMAGE_NAME"
  "docker cp $DOCKER_CONTAINER_NAME:/assembly/. $ASSEMBLY_PATH"
  "docker stop $DOCKER_CONTAINER_NAME"
  "docker container rm -f $DOCKER_CONTAINER_NAME"
)
SIZE=${#ARRAY[*]}
CODE=0
for ((i = 0; i < SIZE; i++)); do
  TASK=${ARRAY[$i]}
  $TASK || CODE=$?
  if test $CODE -ne 0; then
    echo "Task \"$TASK\" error $CODE!"
    return $((100 + i))
  fi
done

echo "${ASSEMBLY_PATH}: $(ls $ASSEMBLY_PATH)"

echo "assembly success"

return 0
