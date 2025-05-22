#!/bin/sh

inotifywait --monitor --event 'create' --exclude swp$ /usr/local/share/public/samba/master/bulk/rischi/invio/ |
    while read dir action file; do
        Rscript --vanilla /usr/local/share/public/bulk/master/03-rischi/estrai_rischi_bulk.R $dir$file
    done
