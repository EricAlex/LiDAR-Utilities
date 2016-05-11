#!/bin/sh

dbNames=( 'Northern_San_Andreas_Fault' );
Dirs=( 'NSAF' );

for ((j=0;j<"${#Dirs[*]}";j=j+1)); do
    cd ${Dirs[$j]};
    
    echo "in directory: "${Dirs[$j]};
    
    EPSG=$(<EPSG.txt);
    count=1;
    
    for laz in `ls *.laz`; do
        xmlfile=${laz%.laz}.xml;
        touch ${xmlfile};

        jsonfile=${laz%.laz}.json;
        touch ${jsonfile};

        txtfile=${laz%.laz}.txt;
        

if [ "$count" -eq 1 ]; then
            echo '<?xml version="1.0" encoding="utf-8"?>
<Pipeline version="1.0">
    <Writer type="writers.pgpointcloud">
            <Option name="connection">host='"'"'localhost'"'"' dbname='"'${dbNames[$j]}'"' user='"'"'ericrussell'"'"'</Option>
            <Option name="table">lidar</Option>
            <Filter type="filters.chipper">
                <Option name="capacity">400</Option>
                <Reader type="readers.text">
                    <Option name="filename">'"${txtfile}"'</Option>
                    <Option name="spatialreference">EPSG:'"${EPSG}"'</Option>
                </Reader>
            </Filter>
    </Writer>
</Pipeline>' > ${xmlfile};
        else
            echo '<?xml version="1.0" encoding="utf-8"?>
<Pipeline version="1.0">
    <Writer type="writers.pgpointcloud">
            <Option name="connection">host='"'"'localhost'"'"' dbname='"'${dbNames[$j]}'"' user='"'"'ericrussell'"'"'</Option>
            <Option name="table">lidar</Option>
            <Option name="overwrite">false</Option>
            <Filter type="filters.chipper">
                <Option name="capacity">400</Option>
                <Reader type="readers.text">
                    <Option name="filename">'"${txtfile}"'</Option>
                    <Option name="spatialreference">EPSG:'"${EPSG}"'</Option>
                </Reader>
            </Filter>
    </Writer>
</Pipeline>' > ${xmlfile};
        fi

: <<'END'
        echo '<?xml version="1.0" encoding="utf-8"?>
<Pipeline version="1.0">
    <Writer type="writers.pgpointcloud">
            <Option name="connection">host='"'"'localhost'"'"' dbname='"'${dbNames[$j]}'"' user='"'"'ericrussell'"'"'</Option>
            <Option name="table">lidar</Option>
            <Option name="overwrite">false</Option>
            <Filter type="filters.chipper">
                <Option name="capacity">400</Option>
                <Reader type="readers.text">
                    <Option name="filename">'"${txtfile}"'</Option>
                    <Option name="spatialreference">EPSG:'"${EPSG}"'</Option>
                </Reader>
            </Filter>
    </Writer>
</Pipeline>' > ${xmlfile};
END

        echo '{
  "pipeline":[
    {
      "type":"readers.las",
      "filename":"'"${laz}"'"
    },
    {
      "type":"writers.text",
      "order":"X,Y,Z",
      "keep_unspecified":"false",
      "quote_header":"false",
      "filename":"'"${txtfile}"'"
    }
  ]
}' > ${jsonfile};
        
        pdal pipeline ${jsonfile};
        pdal pipeline --input ${xmlfile};
        rm ${jsonfile};
        rm ${xmlfile};
        rm ${txtfile};
        echo "	finished: "${count}"/"`ls *.laz | wc -l`;

        count=$((count+1));
    done
    
    cd ..;
done