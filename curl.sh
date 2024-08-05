#! /usr/bin/env bash

set -euo pipefail

curl -H "Host: hello.lab.home" --cacert rootCA.pem https://localhost:8443