###########################################################################
# SERVIZIO MASSIVO PER LA GEOCODIFICA DIRETTA DI INDIRIZZI (> COORDINATE) #
###########################################################################

t0 <- Sys.time()
masteRfun::load_pkgs('masteRgis', 'data.table') |> invisible()

retx <- \(x, xh = TRUE){
    txth <-
    '\n
    Controllare che la tabella fornita corrisponda al seguente schema di 2 colonne:
      - prima colonna: id,
      - seconda colonna: indirizzo completo
    '
    writeLines( paste('ERRORE!\n', x, ifelse(xh, txth, '')), gsub('\\..*$', '.log', fn) )
    stop(x, call. = FALSE)
}

# fn <- file.path(percorsi$smb, 'master', 'bulk', 'geocod', 'invio', 'testD.csv')
fn = commandArgs()[length(commandArgs())]
message('Inizio ad elaborare il file `', basename(fn), '` (', Sys.time() |> format(format = '%d %B, %H:%M:%S'), ')')
y <- tryCatch( fread(fn), error =\(e) NULL )
fn <- fn |> gsub('invio', 'risultati', x = _)

if(is.null(y)) retx('Non riesco a leggere il file.', FALSE)
if(nrow(y) ==  0) retx('Nessun dato da elaborare.', FALSE)
if(ncol(y) < 2) retx('Colonne mancanti.')
if(ncol(y) > 2) retx(paste0('Colonne in numero superiore al richiesto (', ncol(y), ')'))

yr <- rbindlist( lapply( 1:nrow(y), \(x) data.table( y[x, 1], geopelias(y[x, 2], n = 1) ) ) )

fwrite(yr, fn)
tx <- paste0('Elaborazione file `', basename(fn), '` terminata correttamente.\nTempo di esecuzione: ', (Sys.time() - t0) |> format(format = '%M'))
message(tx)
writeLines(tx, gsub('\\..*$', '.log', fn))

rm(list = ls())
gc()
