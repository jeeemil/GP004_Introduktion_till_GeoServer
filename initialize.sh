#!/usr/bin/env bash

docker-compose exec -T postgres /postgis-init.sh
docker-compose exec -T geoserver /geoserver-init.sh
