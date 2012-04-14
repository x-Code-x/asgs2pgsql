#!/bin/bash

# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

source ./global-vars.sh

# extract the shp and csv files out of the zips

for f in "$asgs_dir"/*.zip
do
  b=`basename "$f" '.zip'`
  mkdir -p "$asgs_unzip_dir/$b/"
  unzip "$f" -d "$asgs_unzip_dir/$b/"
done
