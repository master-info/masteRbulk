#########################################################################
# SERVIZIO MASSIVO PER CALCOLO DISTANZE STRADALI E TEMPI DI PERCORRENZA #
#########################################################################

t0 <- Sys.time()
masteRfun::load_pkgs('masteRgis', 'data.table') |> invisible()

retx <- \(x, xh = TRUE){
    txth <-
    '\n
    Controllare che la tabella fornita corrisponda al seguente schema (di 6 o 7 colonne):
      - prime tre colonne: `id`, `longitudine` e `latitudine` del primo punto,
      - colonne terza, quarta e quinta: `id`, `longitudine` e `latitudine` del secondo punto,
      - la settima colonna *opzionale* rappresenta il mezzo di locomozione: `a`uto, `b`ici, `c`ammino (se non presente viene risolto come `a`).
    '
    writeLines( paste('ERRORE!\n', x, ifelse(xh, txth, '')), gsub('\\..*$', '.log', fn) )
    stop(x, call. = FALSE)
}

# fn <- file.path(percorsi$smb, 'master', 'bulk', 'distempi', 'invio', 'test.csv')
fn = commandArgs()[length(commandArgs())]
message('Inizio ad elaborare il file `', basename(fn), '` (', Sys.time() |> format(format = '%d %B, %H:%M:%S'), ')')
y <- tryCatch( fread(fn), error =\(e) NULL )
fn <- gsub('invio', 'risultati', fn)

if(is.null(y)) retx('Non riesco a leggere il file.', FALSE)
if(nrow(y) ==  0) retx('Nessun dato da elaborare.', FALSE)
if(ncol(y) < 6) retx('Colonne mancanti.')
if(ncol(y) > 7) retx(paste0('Colonne in numero superiore al richiesto (', ncol(y), ')'))

if(ncol(y) == 6){
    y[, mz := 'a'] 
} else { 
    setnames(y, 7, 'mz')
    y[, mz := tolower(substr(mz, 1, 1))]
    y[!mz %in% c('b', 'c', 'p'), mz := 'a']
}

# caso `BICI` ('b')
y3 <- y[mz == 'b']
if(nrow(y3) > 0) y1 <- cbind( y1, y1[, c(2, 3, 5, 6)] |> distempi('b') )

# caso `CAMMINO` ('c' e 'p')
y2 <- y[mz %in% c('c', 'p')]
if(nrow(y2) > 0) y2 <- cbind( y2, y2[, c(2, 3, 5, 6)] |> distempi('p') )

# caso `AUTO` (i rimanenti)
y1 <- y[!mz %in% c('b', 'c', 'p')]
if(nrow(y1) > 0) y1 <- cbind( y1, y1[, c(2, 3, 5, 6)] |> distempi('a') )

yr <- rbindlist(list( y1, y2, y3), use.names = TRUE, fill = TRUE)

if(is.null(yr)) retx("L'operazione non è andata a buon fine. Rivedere il contenuto e/o la struttura del file.")
if(nrow(yr) == 0) retx("L'operazione non ha condotto ad alcun risultato valido. Rivedere il contenuto e/o la struttura del file.")

fwrite(yr, fn)
tx <- paste0('Elaborazione file `', basename(fn), '` terminata correttamente.\nTempo di esecuzione: ', (Sys.time() - t0) |> format(format = '%M'))
message(tx)
writeLines(tx, gsub('\\..*$', '.log', fn))

rm(list = ls())
gc()
