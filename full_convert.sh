#!/usr/bin/env bash

if [[ -z "${TRANSXCHANGE_LOGIN}" ]]; then
    echo "export needs TRANSXCHANGE_LOGIN environment variable to be set"
    exit 1
fi
if [[ -z "${TRANSXCHANGE_PASSWORD}" ]]; then
    echo "export needs TRANSXCHANGE_PASSWORD environment variable to be set"
    exit 2
fi

HOST=ftp.tnds.basemap.co.uk
PORT=21

echo "Access to $TRANSXCHANGE_LOGIN:$TRANSXCHANGE_PASSWORD@ftp://$HOST:$PORT"
mkdir -p $(pwd)/data
wget -r --user=$TRANSXCHANGE_LOGIN --password=$TRANSXCHANGE_PASSWORD ftp://$HOST -P $(pwd)/data/

if [ ! -f TransXChange2GTFS_2/NaptanStops.csv ]; then
   pushd TransXChange2GTFS_2 && unzip NaptanStops_unzipthis.zip && popd
fi
docker build -t transxchange2gtfs .
for file in `ls data/$HOST`; do
    if [ ${file: -4} == ".zip" ]; then
        INPUT=data/$HOST/${file}_input
        OUTPUT=data/GTFS/${file}_output
        rm -rf $INPUT/*
        echo "convert $file"
        unzip data/$HOST/$file -d $INPUT
        mkdir -p $OUTPUT
        rm -rf $OUTPUT/*
        docker run --rm -v "$(pwd)/${INPUT}:/srv/input" -v "$(pwd)/${OUTPUT}:/srv/output" transxchange2gtfs
    fi
done
