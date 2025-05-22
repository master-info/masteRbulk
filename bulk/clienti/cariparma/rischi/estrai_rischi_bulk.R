# 1]  se non gia presente, installare l'utility `inotify` usando utente `masterinfo`: `sudo apt install inotify-tools`
# 2a] il percorso radice degli script nello spazio pubblico: `$PUB_PATH/bulk/clienti/cariparma/`
# 2b] il percorso radice dei dati in Samba: `$PUB_PATH/samba/clienti/cariparma/bulk/rischi/`
# 2c] i dati vanno inseriti in `invio`, il risultato viene scritto in `risultati`
# 3a] modificare se necessario il percorso del file dati di ingresso nel server *Samba* in `estrai_rischi_bulk.sh`
# 3b] modificare se necessario il percorso dello script di $R$ in `estrai_rischi_bulk.sh` (il percorso NON deve avere variabili)
# 4]  copiare i file `estrai_rischi_bulk.*` in `$PUB_PATH/bulk/clienti/cariparma/`
# 5]  entrare nel percorso script: `cd $PUB_PATH/bulk/clienti/cariparma/` e rendere `estrai_rischi_bulk.sh` eseguibile: `chmod +x estrai_rischi_bulk.sh`
# 6]  aprire una connessione *multiplex* come: `screen -S <nome>`
# 7]  eseguire lo script: `./estrai_rischi_bulk.sh`
# 8]  per fermare lo script cercare il corrispondente processo `ps -ef | grep inotifywait` da cui desumere il PID e `kill PID`
# 9]  in extremis: `killall inotifywait`

t0 <- Sys.time()
masteRfun::load_pkgs('masteRrischi', 'data.table') |> invisible()

retx <- \(x, xh = TRUE){ 
    txth <- 
    '\n
    Controllare che i dati forniti corrispondano ad una delle forme seguenti:
      - prima colonna: `id`,
      - se tabella di *due* colonne: la seconda colonna rappresenta `indirizzo`,
      - se tabella di *tre* colonne: la seconda colonna rappresenta `longitudine`, la terza colonna rappresenta `latitudine`.
    '
    writeLines( paste('ERRORE!\n', x, ifelse(xh, txth, '')), gsub('\\..*$', '.log', fn) ) 
    stop(x, call. = FALSE) 
}

fn <- '/usr/local/share/public/samba/clienti/cariparma/bulk/rischi/invio/test.csv'
fn = commandArgs()[length(commandArgs())]
message('Inizio ad elaborare il file `', basename(fn), '` (', Sys.time() |> format(format = '%d %B, %H:%M:%S'), ')')
y <- tryCatch( fread(fn), error =\(e) NULL )
fn <- gsub('invio', 'risultati', fn)

if(is.null(y)) retx('Non riesco a leggere il file.', FALSE)
if(nrow(y) ==  0) retx('Nessun dato da elaborare.', FALSE)
if(ncol(y) < 2) retx('Colonne mancanti.')
if(ncol(y) > 3) retx(paste0('Colonne in numero superiore al richiesto (', ncol(y), ')'))

if(ncol(y) == 2){
    if(!is.character(y[, 2] |> unlist())) retx('La seconda colonna deve essere di indirizzi, di tipo carattere.')
    yr <- sapply( y[[2]], masteRgis::geocodifica) |> t() |> as.data.table()
    yr <- yr[, lapply(.SD, unlist)]
    yr <- data.table( yr, estrai_rischi_dt( yr[, .(x_lon, y_lat)]) )
} else {
    if(!is.numeric(y[, 2] |> unlist()) | !is.numeric(y[, 3] |> unlist())) retx('La seconda e terza colonna devono essere coordinate, di tipo numerico.')
    yr <- estrai_rischi_dt( y[, 2:3] )
}
# tryCatch({
#     
#     }, 
#     error = \(e) e, 
#     finally = cat('Si è verificato un errore:\n')
# )
if(is.null(yr)) retx("L'operazione non è andata a buon fine. Rivedere il contenuto e/o la struttura del file.")
if(nrow(yr) == 0) retx("L'operazione non ha condotto ad alcun risultato valido. Rivedere il contenuto e/o la struttura del file.")

y <- data.table(y[, 1] , yr)
fwrite(y, fn)
tx <- paste0('Elaborazione file `', basename(fn), '` terminata correttamente.\nTempo di esecuzione: ', (Sys.time() - t0) |> format(format = '%M'))
message(tx)
writeLines(tx, gsub('\\..*$', '.log', fn))

rm(list = ls())
gc()
