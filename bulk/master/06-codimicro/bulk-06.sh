#!/bin/sh

inotifywait --monitor --event 'create' --exclude swp$ /usr/local/share/public/samba/master/bulk/codimicro/invio/ |
    while read dir action file; do
        Rscript --vanilla /usr/local/share/public/bulk/master/06-codimicro/estrai_codici_micro_bulk.R $dir$file
    done
