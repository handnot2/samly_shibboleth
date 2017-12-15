#!/bin/sh

IDP_IMAGE_TAG=samly_shibb_idp
IDP_CONTAINER=samly_shibb_idp

docker stop ${IDP_CONTAINER}
docker rm ${IDP_CONTAINER}
docker rmi ${IDP_IMAGE_TAG}

echo "To completely remove the bits execute the following command:"
echo "  sudo rm -rf customized-shibboleth-idp"
