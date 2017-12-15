#!/bin/sh

IDP_IMAGE_TAG="samly_shibb_idp"

docker --debug=true build -t ${IDP_IMAGE_TAG} -f Dockerfile .
