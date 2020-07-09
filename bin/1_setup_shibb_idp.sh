#!/bin/sh

# JETTY_BROWSER_SSL_KEYSTORE_PASSWORD - Export Password
# JETTY_BACKCHANNEL_SSL_KEYSTORE_PASSWORD - Backchannel PKCS12 Password

FC_PASSWORD=${FC_PASSWORD:-"shibb-fc"}

SRC="shibb_templates"
DEST="customized-shibboleth-idp"

docker run -it --rm \
  --hostname "shibb.idp" \
  -v $(pwd):/ext-mount \
  unicon/shibboleth-idp init-idp.sh

chmod -R 755 ${DEST}/metadata
chmod -R 755 ${DEST}/views
chmod -R 755 ${DEST}/webapp

C="US"
ST="Midlands"
L="Safeville"
O="ID Federation"
OU="Department of Identities"
CN="shibb.idp"
SUBJ="/C=${C}/ST=${ST}/L=${L}/O=${O}/OU=${OU}/CN=${CN}"

echo ""
echo "Generating Front Channel Certificate ..."
openssl req -new -x509 -sha256 -days 365 -nodes \
  -newkey rsa:4096 \
  -out ${DEST}/credentials/jetty.crt \
  -keyout ${DEST}/credentials/jetty.key \
  -subj "${SUBJ}"

echo ""
echo "Exporting Front Channel Key ..."
openssl pkcs12 -export \
  -passout "pass:${FC_PASSWORD}" \
  -inkey ${DEST}/credentials/jetty.key \
  -in ${DEST}/credentials/jetty.crt \
  -out ${DEST}/credentials/idp-browser.p12


IDP_ENTITYID=`grep idp.entityID ${DEST}/conf/idp.properties`
SP_ENTITYID="sp.entityID=urn:samly.howto:samly_sp"
STORE_PW=`grep idp.sealer.storePassword ${DEST}/conf/idp.properties`
KEY_PW=`grep idp.sealer.keyPassword ${DEST}/conf/idp.properties`
FC_PW="jetty.sslContext.keyStorePassword=${FC_PASSWORD}"
BC_PW="jetty.backchannel.sslContext.keyStorePassword="

cp ${SRC}/conf/idp.properties ${DEST}/conf/idp.properties
echo "${IDP_ENTITYID}" >> ${DEST}/conf/idp.properties
echo "${SP_ENTITYID}" >> ${DEST}/conf/idp.properties

mkdir -p ${DEST}/ext-conf
echo "${BC_PW}" > ${DEST}/ext-conf/idp-secrets.properties
echo "${FC_PW}" >> ${DEST}/ext-conf/idp-secrets.properties
echo "${STORE_PW}" >> ${DEST}/ext-conf/idp-secrets.properties
echo "${KEY_PW}" >> ${DEST}/ext-conf/idp-secrets.properties

cp ${SRC}/conf/ldap.properties ${DEST}/conf/ldap.properties
cp ${SRC}/conf/logback.xml ${DEST}/conf/logback.xml
cp ${SRC}/conf/saml-nameid.properties ${DEST}/conf/
cp ${SRC}/conf/attribute-filter.xml ${DEST}/conf/
cp ${SRC}/conf/attribute-resolver.xml ${DEST}/conf/
cp ${SRC}/conf/metadata-providers.xml ${DEST}/conf/
cp ${SRC}/conf/relying-party.xml ${DEST}/conf/
cp ${SRC}/images/shibb-idp.png ${DEST}/webapp/images/

cp ${SRC}/metadata/sp_metadata.xml ${DEST}/metadata/

mkdir -p ${DEST}/messages
cp ${SRC}/messages/messages.properties ${DEST}/messages/

echo "Done"

echo ""
echo "Set Backchannel PKCS12 password in:"
echo ""
echo "  ./${DEST}/ext-conf/idp-secrets.properties"
echo ""
echo "Should match what was provided earlier."
echo ""
