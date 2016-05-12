#!/bin/sh

dbName=
step=1;

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

  entries=`psql -At -U ericrussell -d ${dbName} -c "SELECT COUNT(*) FROM lidar;"`;

  entry_step=$(($entries/32));
  gain=$(($entry_step-1));
  file_record="";

  for j in `seq 1 ${entry_step} ${entries}`; do
    {
      jsonfile=${dbName}_$j.json;
      lazfile=${dbName}_temp_$j.laz;
      echo '{
  "pipeline":[' > ${jsonfile};

      if [ "$(($j + $gain))" -le "${entries}" ]; then
        echo '    {
      "type":"readers.pgpointcloud",
      "connection":"host='"'"'localhost'"'"' dbname='"'${dbName}'"' user='"'"'ericrussell'"'"'",
      "table":"lidar",
      "column":"pa",
      "where":"id between '"${j}"' and '"$(($j + $gain))"'"
    },
    {
      "type":"filters.decimation",
      "step":"'"${step}"'"
    },' >> ${jsonfile};
      else
        echo '    {
      "type":"readers.pgpointcloud",
      "connection":"host='"'"'localhost'"'"' dbname='"'${dbName}'"' user='"'"'ericrussell'"'"'",
      "table":"lidar",
      "column":"pa",
      "where":"id between '"${j}"' and '"${entries}"'"
    },
    {
      "type":"filters.decimation",
      "step":"'"${step}"'"
    },' >> ${jsonfile};
      fi
      echo '    "'"${lazfile}"'"
  ]
}' >> ${jsonfile};
      pdal pipeline ${jsonfile};

      rm ${jsonfile};
    } &
  done

  wait

  for temp_file in `ls ${dbName}_temp_*.laz`; do
    file_record=${file_record}'"'${temp_file}'",\n';
  done

  file_record=${file_record%,\n};

  jsonfile=${dbName}.json;
  pcdfile=${dbName}_${step}th.pcd;

  echo '{
  "pipeline":[
      '"${file_record}"'
      {
        "type": "filters.merge"
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
  rm ${dbName}_temp_*.laz;

	echo "Finished downsample "${dbName};
else
    # ruh-roh
    echo "Database ""'"${dbName}"'"" does not exist."
    exit
fi