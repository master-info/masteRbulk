#!/bin/sh

inotifywait --monitor --event 'create' --exclude swp$ /usr/local/share/public/samba/master/bulk/percorsi/invio/ |
    while read dir action file; do
        Rscript --vanilla /usr/local/share/public/bulk/master/02-percorsi/calcola_percorsi_bulk.R $dir$file
    done
