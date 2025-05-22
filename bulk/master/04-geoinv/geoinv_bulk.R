#################################################################################
# SERVIZIO MASSIVO PER LA GEOCODIFICA INVERSA DI PUNTI (COORDINATE > INDIRIZZO) #
#################################################################################

t0 <- Sys.time()
masteRfun::load_pkgs('masteRgis', 'data.table') |> invisible()

retx <- \(x, xh = TRUE){
    txth <-
    '\n
    Controllare che la tabella fornita corrisponda al seguente schema di 2 colonne:
      - prima colonna: id,
      - seconda colonna: longitudine del punto,
      - terza colonna: latitudine del punto
    '
    writeLines( paste('ERRORE!\n', x, ifelse(xh, txth, '')), gsub('\\..*$', '.log', fn) )
    stop(x, call. = FALSE)
}

fn <- file.path(percorsi$smb, 'master', 'bulk', 'geoinv', 'invio', 'testI.csv')
# fn = commandArgs()[length(commandArgs())]
message('Inizio ad elaborare il file `', basename(fn), '` (', Sys.time() |> format(format = '%d %B, %H:%M:%S'), ')')
y <- tryCatch( fread(fn), error =\(e) NULL )
fn <- fn |> gsub('invio', 'risultati', x = _)

if(is.null(y)) retx('Non riesco a leggere il file.', FALSE)
if(nrow(y) ==  0) retx('Nessun dato da elaborare.', FALSE)
if(ncol(y) < 3) retx('Colonne mancanti.')
if(ncol(y) > 3) retx(paste0('Colonne in numero superiore al richiesto (', ncol(y), ')'))

yr <- rbindlist( lapply( 1:nrow(y), \(x) data.table( y[x, 1], geopelias(y[x, 2], y[x, 3], n = 1) |> _[, 5:7] ) ) )
yr[, descrizione := gsub(', Italia', '', descrizione)]

fwrite(yr, fn)
tx <- paste0('Elaborazione file `', basename(fn), '` terminata correttamente.\nTempo di esecuzione: ', (Sys.time() - t0) |> format(format = '%M'))
message(tx)
writeLines(tx, gsub('\\..*$', '.log', fn))

rm(list = ls())
gc()
