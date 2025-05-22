#!/bin/sh

inotifywait --monitor --event 'create' --exclude swp$ /usr/local/share/public/samba/master/bulk/kml2shp/invio/ |
    while read dir action file; do
        Rscript --vanilla /usr/local/share/public/bulk/master/11-kml2shp/converti_kml_shp_bulk.R $dir$file
    done
