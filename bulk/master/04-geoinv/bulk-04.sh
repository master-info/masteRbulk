#!/bin/sh

inotifywait --monitor --event 'create' --exclude swp$ /usr/local/share/public/samba/master/bulk/geoinv/invio/ |
    while read dir action file; do
        Rscript --vanilla /usr/local/share/public/bulk/master/04-geoinv/geoinv_bulk.R $dir$file
    done
