#!/bin/bash

SOURCE=api.yaml
TARGET=asyncapi.yaml

for i in Pro6 Pro7
do
	./yaml2asyncapi $i/$SOURCE $i/$TARGET
	# npm install -g @asyncapi/html-template@0.23.0
	# npm install -g @asyncapi/generator
	ag $i/$TARGET @asyncapi/html-template@0.23.4 -o ./docs/$i --force-write -p singleFile=true # -p outFilename=pro6-api.html
done
