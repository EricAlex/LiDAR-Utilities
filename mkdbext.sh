#!/bin/sh

dbName=

while getopts "d:" arg
do
        case $arg in
        	 d)
                dbName=$OPTARG
                ;;
             ?)
            echo "unkonw argument"
        exit 1
        ;;
        esac
done

if [ -z "$dbName" ]; then
    echo "You must specify the database name with -d option"
    exit
fi

if psql -lqt | cut -d \| -f 1 | grep -qw ${dbName}; then
    # database exists
    while true; do
        read -p "'"${dbName}"'"" already exits, do you wish to drop it and recreate it? (y/n): " yn
        case $yn in
            [Yy]* ) dropdb ${dbName};createdb ${dbName} -O ericrussell -E UTF8;psql -U ericrussell -d ${dbName} -c "CREATE EXTENSION postgis; CREATE EXTENSION pointcloud; CREATE EXTENSION pointcloud_postgis;";break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
else
    # ruh-roh
    createdb ${dbName} -O ericrussell -E UTF8;
	psql -U ericrussell -d ${dbName} -c "CREATE EXTENSION postgis; CREATE EXTENSION pointcloud; CREATE EXTENSION pointcloud_postgis;";
fi