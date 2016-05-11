#!/bin/sh

dbNames=( 'Northern_San_Andreas_Fault' );

for dbname in ${dbNames[@]}; do
    createdb ${dbname} -O ericrussell -E UTF8;
    psql -U ericrussell -d ${dbname} -c "CREATE EXTENSION postgis; CREATE EXTENSION pointcloud; CREATE EXTENSION pointcloud_postgis;"
done