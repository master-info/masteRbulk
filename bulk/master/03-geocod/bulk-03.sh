#!/bin/sh

inotifywait --monitor --event 'create' --exclude swp$ /usr/local/share/public/samba/master/bulk/geocod/invio/ |
    while read dir action file; do
        Rscript --vanilla /usr/local/share/public/bulk/master/03-geocod/geocod_bulk.R $dir$file
    done
