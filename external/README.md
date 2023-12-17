Docker compose for external component:
 - mirror image
 - local repo
 - proxy squid ssl

CA

openssl genrsa -des3 -out MOCK_CA.key 2048
openssl rsa -in MOCK_CA.key-out MOCK_CA.key
openssl req -x509 -new -nodes -key  MOCK_CA.key -sha256 -days 1825 -out  MOCK_CA.crt

## manual generate mock key/cert
export DOMAIN=repo.internal
openssl genrsa -out $DOMAIN.key 2048
CN=$DOMAIN openssl req -new -key $DOMAIN.key -out $DOMAIN.csr  -config ../ca/custom.cnf
openssl x509 -req -in $DOMAIN.csr -CA ./files/ca.pem -CAkey ./files/ca.pem -CAcreateserial -out $DOMAIN.crt -days 825 -sha256 -extfile ./ca/repo.internal.ext
openssl x509 -in $DOMAIN.crt -text
