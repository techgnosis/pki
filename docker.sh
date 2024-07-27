#! /usr/bin/env bash

set -euo pipefail

docker run -it --rm -v $PWD:/root -w /root ubuntu:latest bash