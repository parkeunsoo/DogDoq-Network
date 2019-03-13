rm -fr crypto-config
rm -fr channel-artifacts
rm -fr docker-compose-e2e.yaml
mkdir channel-artifacts
docker rm -f $(docker ps -a -q)
docker volume prune