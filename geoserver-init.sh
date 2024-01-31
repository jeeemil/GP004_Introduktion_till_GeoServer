#!/usr/bin/env bash
cp -a /koulutus $GEOSERVER_DATA_DIR
chown -R geoserveruser.geoserverusers $GEOSERVER_DATA_DIR/koulutus
cd $GEOSERVER_DATA_DIR
mv OpenStreetMap/HelsinkiRegion/ ./Helsinki.osm.shp
cd Helsinki.osm.shp
for ext in dbf prj shp shx ; do mv gis.osm_buildings_a_free_1.$ext buildings.$ext ; done
