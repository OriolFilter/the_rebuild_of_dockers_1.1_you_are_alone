#!/bin/bash
FOLDER=$(dirname $0)
PASSWD="abc123"
cd $FOLDER
CERTFOLDER="stack/cert_ssl"

openssl genrsa -des3  -passout pass:$PASSWD -out $CERTFOLDER/servidor.key 2048
#openssl genrsa -des3  -out $CERTFOLDER/servidor.key 2048
mv $CERTFOLDER/servidor.key $CERTFOLDER/servidor.key.vell
openssl rsa -in $CERTFOLDER/servidor.key.vell -passin pass:$PASSWD -out $CERTFOLDER/servidor.key
#openssl rsa -in $CERTFOLDER/servidor.key.vell -out $CERTFOLDER/servidor.key
res="ES\nBarcelona\nBarcelona\nOFA\n\n\n\n\n\n"
printf "$res" | openssl req -new -key $CERTFOLDER/servidor.key -out $CERTFOLDER/servidor.csr
openssl x509 -req -days 365 -in $CERTFOLDER/servidor.csr -signkey $CERTFOLDER/servidor.key -out $CERTFOLDER/servidor.crt
