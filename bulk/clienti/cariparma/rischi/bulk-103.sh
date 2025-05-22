#!/bin/sh

inotifywait --monitor --event 'create' --exclude swp$ /usr/local/share/public/samba/clienti/cariparma/bulk/rischi/invio/ |
    while read dir action file; do
        Rscript --vanilla /usr/local/share/public/bulk/clienti/cariparma/103-rischi/estrai_rischi_bulk.R $dir$file
    done
