Tested with `OpenSSL 3.0.13 30 Jan 2024 (Library: OpenSSL 3.0.13 30 Jan 2024)` on Linux

# Core Concepts and Terms

Symmetric encryption - a shared key is used by both parties. Less CPU-intensive, but difficult to share the key in a secure manner

Asymmetric encryption - private key and public key. Encrypt data with the public key and only the private key can decrypt

Hash function - takes an input and produces a fixed size output. The same input will always produce the same output

Digest or Hash - the output of a hash function

Signature - a private key can encrypt a digest and that's called a signature. Only a private key can create a signature

Certificate - a file that contains information about the owner of the certificate, the public key of the owner of the certificate, and a signature from a Certificate Authority that created the certificate

Certificate Authority (CA) - a business or service that has the means to verify that someone who says they own a domain actually owns the domain and provides a certificate to the domain owner so other can verify



### DIY digital signature
To digitally sign a message, make a hash of the message using a hashing function (like SHA-256). Then encrypt the hash with a private key. Send the message and the hash to someone with the public key. They decrypt the encrypted hash and they hash the original message. If the decrypted hash and the new hash match, the message has not been tampered with and they can be sure that it comes from the private key holder

###### make the private key
openssl genrsa \\
-out private_key_rsa.pem 2048

###### make a public key from the private key
openssl rsa \\
-in private_key_rsa.pem \\
-pubout \\
-out public_key_rsa.pem

###### print a hash/digest to STDOUT so you can see what it looks like
openssl dgst \\
-sha256 \\
message

###### encrypt (sign) the digest into a binary file
openssl dgst \\
-sha256 \\
-sign private_key_rsa.pem \\
-out message.bin \\
message

###### verify the signature
openssl dgst \\
-sha256 \\
-verify public_key_rsa.pem \\
-signature message.bin \\
message

### DIY TLS
TLS uses a "hybrid" scheme. The client creates a symmetric encryption key, then encrypts that key with the public key and sends it to the server which decrypts it with the private key. Then all of the session data is encrypted/decrypted with the symmetric key since it's more computationally efficient.

###### create a symmetric encryption key
openssl rand -base64 32 > symmetric_key

###### encrypt the symmetric encryption key with the public key
openssl pkeyutl \\
-encrypt \\
-pubin \\
-inkey public_key_rsa.pem \\
-in symmetric_key \\
-out symmetric_key.bin

###### decrypt the encrypted symmetric key with the private key
openssl pkeyutl \\
-decrypt \\
-inkey private_key_rsa.pem \\
-in symmetric_key.bin

###### client uses the symmetric key to encrypt the session data
openssl enc \\
-aes-256-cbc \\
-in http_request \\
-out http_request.bin \\
-pbkdf2 \\
-pass file:symmetric_key




### DIY certificate authority

###### make private key for root certificate
openssl genrsa \\
-out root_private_key.pem 2048


###### make CSR for root certificate
openssl req \\
-new \\
-key root_private_key.pem \\
-out rootCA.csr

###### make the root certificate
openssl x509 -req \\
-in rootCA.csr \\
-signkey root_private_key.pem \\
-out rootCA.pem \\
-days 365

*Note - x.509 is the standard for certificates*


###### make the private key for domain cert
openssl genrsa \\
-out domain_private_key.pem 2048

###### make the CSR for the domain cert
openssl req \\
-new \\
-key domain_private_key.pem \\
-out domain.csr

*Note - the domain private key is not part of the cert, but it is provided to generate a public key that is part of the cert. that public key is used by clients to encrypt a symmetric key to initiate TLS*


###### make the domain cert from the root cert
openssl x509 -req \\
-in domain.csr \\
-CA rootCA.pem \\
-CAkey root_private_key.pem \\
-out domain_cert.pem \\
-days 365

*Note - the difference between the root cert creation and the domain cert creation is -CA to provide the root cert. This cert will appear in the chain and will work to verify the domain cert*

###### verify the cert is from the root cert
openssl verify -CAfile rootCA.pem domain_cert.pem

###### view a cert
openssl x509 -in domain_cert.pem -text -noout

###### view a cert from a domain
openssl s_client \\
-servername localhost \\
-connect localhost:8081
