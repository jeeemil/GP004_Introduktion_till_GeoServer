#!/usr/bin/env bash

export PGHOST=localhost
export PGUSER=postgres
export PGPASSWORD=$POSTGRES_PASS

apt update
apt-get -y install gdal-bin osm2pgsql unzip

until pg_isready -h $PGHOST
do
    echo "Waiting for database to start"
    sleep 1
done
echo "Database started."


psql -d postgres -c "CREATE DATABASE gs_training;"
psql -d gs_training -c "CREATE SCHEMA lipas;"
psql -d gs_training -c "CREATE SCHEMA suomi;"

psql -d gs_training -c "CREATE EXTENSION IF NOT EXISTS postgis;"

# LIPAS-datatuonti
echo "Importing LIPAS data"
export SHAPE_ENCODING="ISO-8859-1" # Fiksaa ogr2ogr:n merkistöongelman
for i in alueet reitit pisteet ; do
    wget 'https://gispo-training-data.s3.eu-central-1.amazonaws.com/public/lipas_kaikki_'$i'.zip'
    unzip lipas_kaikki_$i.zip
    ogr2ogr -lco SCHEMA=lipas -f PostgreSQL PG:"dbname='gs_training' host='$PGHOST' port='5432' user='$PGUSER' password='$PGPASSWORD'" lipas_kaikki_$i.shp -lco GEOMETRY_NAME=geom -lco FID=fid -lco SPATIAL_INDEX=GIST
done

# OSM-datatuonti
echo "Importing OSM data"
wget https://gispo-training-data.s3.eu-central-1.amazonaws.com/public/finland-latest.osm.pbf
echo "$PGHOST:5432:gs_training:$PGUSER:$PGPASSWORD" > $HOME/.pgpass
chmod 600 $HOME/.pgpass
osm2pgsql --output-pgsql-schema=suomi -s -C 1200 -d gs_training -U $PGUSER -H $PGHOST -P 5432 finland-latest.osm.pbf
psql -d gs_training -c "ALTER TABLE suomi.planet_osm_roads RENAME TO osm_tiet;"
