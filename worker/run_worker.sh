#!/bin/bash

source .env

./config.sh --url https://github.com/AndreasPrang/test-build-on-arm --token $TOKEN
./run.sh
