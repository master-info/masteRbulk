#!/bin/sh

inotifywait --monitor --event 'create' --exclude swp$ /usr/local/share/public/samba/master/bulk/bacini/invio/ |
    while read dir action file; do
        Rscript --vanilla /usr/local/share/public/bulk/master/06-bacini/costruisci_bacini_bulk.R $dir$file
    done
