############################################
# SERVIZIO DI CONVERSIONE KML IN SHAPEFILE #
############################################

t0 <- Sys.time()
masteRfun::load_pkgs('sf') |> invisible()

retx <- \(x, xh = TRUE){
    txth <- ''
    writeLines( paste('ERRORE!\n', x, ifelse(xh, txth, '')), gsub('\\..*$', '.log', fn) )
    stop(x, call. = FALSE)
}

# fn <- file.path(percorsi$smb, 'master', 'bulk', 'kml2shp', 'invio', 'test.kml')
fn = commandArgs()[length(commandArgs())]
message('Inizio ad elaborare il file `', basename(fn), '` (', Sys.time() |> format(format = '%d %B, %H:%M:%S'), ')')
y <- tryCatch( st_read(fn, quiet = TRUE), error =\(e) NULL )
fn <- fn |> gsub('invio', 'risultati', x = _)

if(is.null(y)) retx('Non riesco a leggere il file.', FALSE)
if(nrow(y) ==  0) retx('Nessun dato da elaborare.', FALSE)

y  |> subset(select = which(!is.na(y))) |> st_write(gsub('\\..*$', '.shp', fn), append = FALSE, quiet = TRUE)

tx <- paste0('Elaborazione file `', basename(fn), '` terminata correttamente.\nTempo di esecuzione: ', (Sys.time() - t0) |> format(format = '%M'))
message(tx)
writeLines(tx, gsub('\\..*$', '.log', fn))

rm(list = ls())
gc()
