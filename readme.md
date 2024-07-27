Tested with `OpenSSL 3.0.13 30 Jan 2024 (Library: OpenSSL 3.0.13 30 Jan 2024)` on Linux

Core Concepts and Terms
-----------------------
Symmetric encryption - a shared key is used by both parties. Faster, but difficult to share the key in a secure manner

Asymmetric encryption - private key and public key. Encrypt data with the public key and only the private key can decrypt

Hash function - takes an input and produces a fixed size output. The same input will always produce the same output

Digest or Hash - the output of a hash function

Signature - a private key can encrypt a digest and that's called a signature. Only a private key can create a signature

Certificate - a file that contains information about the owner of the certificate, the public key of the owner of the certificate, and a signature from a Certificate Authority

Certificate Authority (CA) - a business or service that has the means to verify that someone who says they own a domain actually owns the domain

digital signature
------------------
a message
a hash of the message, using a hashing function (like SHA-256)
encrypt the hash with a private key
the message and the hash are sent to someone with the public key
they decrypt the encrypted hash
they hash the original message
if the decrypted hash and the new hash match, the message has not been tampered with and it comes from the private key holder

certificates
------------------
created from a certificate authority (CA). A CA is an entity like a business that has the ability to verify the claim that someone owns a particular domain. Used to be companies like Verisign but now it's mainly Let's Encrypt doing it automatically.

a certificate is a file that contains: information on the subject, the subjects public key, and a signature created from the CAs private key. The signature is made from a hash of all the data in the certificate including the subjects public key

# make the private key
openssl genrsa \
-out private_key_rsa.pem 2048

# make a public key from the private key
openssl rsa \
-in private_key_rsa.pem \
-pubout \
-out public_key_rsa.pem

# hash some data (digest)
openssl dgst \
-sha256 \
message

# make the digest and sign it
openssl dgst \
-sha256 \
-sign private_key_rsa.pem \
-out message.bin \
message

openssl dgst \
-sha256 \
-verify public_key_rsa.pem \
-signature message.bin \
message

# how does TLS encrypt data?
TLS uses a "hybrid" scheme. The client creates a symmetric encryption key, then encrypts that key with the public key and sends it to the server which decrypts it with the private key. then all of the session data is encrypted with the symmetric key.

# create a symmetric encryption key
openssl rand -base64 32 > symmetric_key

# encrypt the symmetric encryption key with the public key
openssl pkeyutl \
-encrypt \
-pubin \
-inkey public_key_rsa.pem \
-in symmetric_key \
-out symmetric_key.bin

# send the encrypted symmetric key to the server

# decrypt the encrypted symmetric key with the private key
openssl pkeyutl \
-decrypt \
-inkey private_key_rsa.pem \
-in symmetric_key.bin

# client uses the symmetric key to encrypt the session data
openssl enc \
-aes-256-cbc \
-in http_request \
-out http_request.bin \
-pbkdf2 \
-pass file:symmetric_key






keys
-----
private and public
they are not two exact halves of a whole. they are fundamentally different
generate the private key  
then use the private key to generate the public key  

certs
---------

# make private key for root certificate
openssl genrsa \
-out root_private_key.pem 2048


# make CSR for root certificate
openssl req \
-new \
-key root_private_key.pem \
-out rootCA.csr

# make the root certificate
# x.509 is the standard for certificates
openssl x509 -req \
-days 365 \
-in rootCA.csr \
-signkey root_private_key.pem \
-out rootCA.pem

# make the private key for endpoint cert
openssl genrsa \
-out endpoint_private_key.pem 2048

# make the CSR for the endpoint cert
openssl req \
-new \
-key endpoint_private_key.pem \
-out endpoint.csr


# make the endpoint cert from the root cert
openssl x509 -req \
-in endpoint.csr \
-CA rootCA.pem \
-CAkey root_private_key.pem \
-out endpoint_cert.pem \
-days 365

# verify the cert is from the root cert
openssl verify -CAfile rootCA.pem endpoint_cert.pem

# view a cert
openssl x509 -in endpoint_cert.pem -text -noout





