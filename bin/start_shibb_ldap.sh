#!/bin/sh

DATA_CONTAINER_DIR="${PWD}/samly_ldap_dv"
LDAP_HOSTNAME="samly.ldap"
LDAP_ADMIN_PASSWORD="ldapadmin"

docker run -d \
  --name samly_ldap \
  --hostname "${LDAP_HOSTNAME}" \
  --env LDAP_ORGANIZATION="Samly Shibboleth Identity Provider" \
  --env LDAP_DOMAIN="example.org" \
  --env LDAP_ADMIN_PASSWORD="${LDAP_ADMIN_PASSWORD}" \
  --volume ${DATA_CONTAINER_DIR}/ldap:/var/lib/ldap \
  --volume ${DATA_CONTAINER_DIR}/config:/etc/ldap/slapd.d \
  --volume ${PWD}/ldif:/container/service/slapd/assets/config/bootstrap/ldif/custom \
  osixia/openldap:1.1.11 --copy-service
