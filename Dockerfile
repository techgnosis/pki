from ubuntu:24.10

run apt update && apt install -y openssl
copy traefik /usr/bin/