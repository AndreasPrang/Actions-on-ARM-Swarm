#/bin/bash

./buildImage.sh

docker stack deploy --compose-file docker-compose.yml ACTIONS
