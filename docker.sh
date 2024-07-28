#! /usr/bin/env bash

set -euo pipefail

docker run -it --rm -v $PWD:/root -w /root -p 8081:443 pkilearn:1 bash