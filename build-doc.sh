#!/bin/bash

SOURCE=api.yaml
TARGET=asyncapi.yaml

for i in Pro6 Pro7
do
	if [ $i == 'Pro7' ]
	then
		exit
	fi

	./yaml2asyncapi $i/$SOURCE $i/$TARGET
	# npm install -g @asyncapi/html-template@0.23.0
	# npm install -g @asyncapi/generator
	ag $i/$TARGET @asyncapi/html-template@0.23.1 -o $i/docs --force-write -p singleFile=true # -p outFilename=pro6-api.html
done
