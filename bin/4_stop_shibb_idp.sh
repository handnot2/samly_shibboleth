#!/bin/sh

IDP_CONTAINER=samly_shibb_idp

docker stop ${IDP_CONTAINER}
docker rm ${IDP_CONTAINER}
