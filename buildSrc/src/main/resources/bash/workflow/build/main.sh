echo "build start..."

docker image prune -f
CODE=0
export DOCKER_IMAGE_NAME=docker_${GITHUB_RUN_NUMBER}_${GITHUB_RUN_ID}_image
docker build --no-cache \
  -t $DOCKER_IMAGE_NAME \
  --build-arg "BUILD_TYPE=$BUILD_TYPE" \
  -f $RESOURCES_PATH/docker/Dockerfile . || CODE=$?
if test $CODE -ne 0; then
  echo "Build error $CODE!"
  return 11
fi

export DOCKER_CONTAINER_NAME=docker_${GITHUB_RUN_NUMBER}_${GITHUB_RUN_ID}_container
export ASSEMBLY_PATH=assembly_${GITHUB_RUN_NUMBER}_${GITHUB_RUN_ID}
rm -rf $ASSEMBLY_PATH
mkdir -p $ASSEMBLY_PATH || return 21

. $WORKFLOW/build/assembly.sh || CODE=$?
if test $CODE -ne 0; then
  echo "Assembly error $CODE!"
  return 31
fi

echo "build success"

return 0
