#################################################################
# SERVIZIO MASSIVO PER LA VISUALIZZAZIONE DI PERCORSI FRA PUNTI #
#################################################################

t0 <- Sys.time()
masteRfun::load_pkgs('masteRgis', 'data.table', 'htmlwidgets') |> invisible()

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

# fn <- file.path(percorsi$smb, 'master', 'bulk', 'percorsi', 'invio', 'test.csv')
fn = commandArgs()[length(commandArgs())]
message('Inizio ad elaborare il file `', basename(fn), '` (', Sys.time() |> format(format = '%d %B, %H:%M:%S'), ')')
y <- tryCatch( fread(fn), error =\(e) NULL )
fn <- fn |> gsub('invio', 'risultati', x = _)
fnz <- fn |> gsub('(.*)csv$', '\\1zip', x = _)

if(is.null(y)) retx('Non riesco a leggere il file.', FALSE)
if(nrow(y) ==  0) retx('Nessun dato da elaborare.', FALSE)
if(ncol(y) < 6) retx('Colonne mancanti.')
if(ncol(y) > 7) retx(paste0('Colonne in numero superiore al richiesto (', ncol(y), ')'))

if(ncol(y) == 6){
    y[, mz := 'a'] 
} else { 
    setnames(y, 7, 'mz')
    y[, mz := tolower(substr(mz, 1, 1))]
    y[mz == 'p', mz := 'c']
    y[!mz %in% c('b', 'c'), mz := 'a']
}

tmpd <- crea_temp_dir('bulk')
for(x in 1:nrow(y)){
    yx <- y[x]
    percorso( yx[, 2:3] |> as.numeric(), yx[, 5:6] |> as.numeric(), ifelse(yx$mz == 'c', 'p', yx$mz), mp = TRUE, std = FALSE ) |> 
        saveWidget(file.path(tmpd, paste0(yx[, 1], '_', yx[, 4], '_', yx[, 7], '.html')))
} 
if(file.exists(fnz)) file.remove(fnz)
zip(fnz, list.files(tmpd, 'html$', full.names = TRUE), '-j') |> suppressWarnings()
system(paste('rm -rf ', tmpd))

tx <- paste0('Elaborazione file `', basename(fn), '` terminata correttamente.\nTempo di esecuzione: ', (Sys.time() - t0) |> format(format = '%M'))
message(tx)
writeLines(tx, gsub('\\..*$', '.log', fn))

rm(list = ls())
gc()
