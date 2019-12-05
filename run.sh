#/bin/bash

./buildImage.sh

source .env

cat docker-compose.yml | sed "s/TOKEN-VALUE/${TOKEN}/g" | docker stack deploy --compose-file - ACTIONS
