#! /usr/bin/env bash

set -euo pipefail

docker run -it --rm -v $PWD:/root -w /root -p 8443:443 golang:1.22 bash