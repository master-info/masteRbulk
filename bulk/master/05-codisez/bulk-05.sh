#!/bin/sh

inotifywait --monitor --event 'create' --exclude swp$ /usr/local/share/public/samba/master/bulk/codisez/invio/ |
    while read dir action file; do
        Rscript --vanilla /usr/local/share/public/bulk/master/05-codisez/estrai_codici_sezioni_bulk.R $dir$file
    done
