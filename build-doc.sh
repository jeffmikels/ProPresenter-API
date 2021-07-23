#!/bin/bash

SOURCE=pro6-api.yaml
TARGET=pro6-api-asyncapi.yaml
DOCTARGET=pro6_docs

./yaml2asyncapi $SOURCE $TARGET

# npm i -g @asyncapi/generator
ag $TARGET @asyncapi/html-template -o $DOCTARGET
