#! /usr/bin/env bash

set -euo pipefail

echo "https://github.com/caddyserver/caddy/releases/download/v2.8.4/caddy_2.8.4_linux_arm64.tar.gz"

docker run -it --rm -v $PWD:/root -w /root ubuntu:latest bash