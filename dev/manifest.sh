docker build -t tsxcloud/enshrouded-arm:amd64 .
docker push tsxcloud/enshrouded-arm:amd64

docker manifest create --amend tsxcloud/enshrouded-arm:latest \
  tsxcloud/enshrouded-arm:amd64 \
  tsxcloud/enshrouded-arm:arm64

docker manifest push --purge tsxcloud/enshrouded-arm:latest
