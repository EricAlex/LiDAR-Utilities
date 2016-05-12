#!/bin/sh

dbName=
step=10;

while getopts "d:s:" arg
do
        case $arg in
        	 d)
                dbName=$OPTARG
                ;;
             s)
                step=$OPTARG
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
    jsonfile=${dbName}.json;
	pcdfile=${dbName}.pcd;

	echo '{
  "pipeline":[
    {
      "type":"readers.pgpointcloud",
      "connection":"host='"'"'localhost'"'"' dbname='"'${dbName}'"' user='"'"'ericrussell'"'"'",
      "table":"lidar",
      "column":"pa"
    },
    {
      "type":"filters.decimation",
      "step":"'"${step}"'"
    },
    {
      "type":"writers.pcd",
      "compression":"true",
      "filename":"'"${pcdfile}"'"
    }
  ]
}' > ${jsonfile};

	pdal pipeline ${jsonfile};

	rm ${jsonfile};

	echo "Finished downsample "${dbName};
else
    # ruh-roh
    echo "Database ""'"${dbName}"'"" does not exist."
    exit
fi