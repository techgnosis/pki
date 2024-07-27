from ubuntu:24.10

copy endpoint_cert.pem /root/cert.pem
copy endpoint_private_key.pem /root/key.pem

run apt update && apt install -y caddy