## masteRbulk

Creazione di servizi di ricerca ed elaborazione dati di tipo *massivo*.

Ogni *servizio* deve essere scritto utilizzando il linguaggio *R*, e viene eseguito in produzione come *servizio* del sistema operativo Linux.

A parte il file `R` contenente il codice per elaborare la richiesta nello specifico, che puo essere chiamato in qualunque modo, il servizio consiste di altri due file ausiliari:
- `bulk-<blk_id>.sh` con il codice *bash* per l'esecuzione del servizio *inotify* che monitora il percorso prestabilito nel server Samba dove collocare i dati e recuperare i risultati
- `bulk-<blk_id>.service` che consente la configurazione del servizio del sistema operativo

Per implementare il servizio, si proceda come segue:

  - creare il percorso in *samba* con i due spazi interni `invio` e `risultati`, e successivamente 
    applicare i permessi ad entrambi i livelli per assicurare l'esecuzione: `chmod -R 775 <percorso>`

  - creare il file con il codice $R$ da eseguire, poi copiarlo nello spazio `bulk` pubblico

  - copiare il file *bash* di avvio `.sh` nello spazio `bulk` pubblico
  
  - applicare i permessi per assicurare l'esecuzione: `chmod -R 775 <percorso>`

  - accedere ad ubuntu con un utente amministrativo (*sudoer*, sulla macchina di sviluppo si chiama `masterdev`)

  - creare il file di servizio:
    ```
    sudo nano /etc/systemd/system/bulk-<blk_id>.service
    ```
    con il seguente contenuto:
    ```
    [Unit]
    Description=BULK <blk_id>. <descrizione>. @2025 MaSTeR Information [per <azienda>] 
    After=network.target
    
    [Service]
    User=masterdev
    Group=public
    ExecStart=/bin/sh /usr/local/share/public/bulk/master/<blk_id>-<blk_nm>/bulk-<blk_id>.sh
    Restart=always
    
    [Install]
    WantedBy=default.target
    ```
    
  - fai leggere la nuova configurazione al gestore di servizi: 
    ```
    sudo systemctl daemon-reload
    ```
    
  - avvia il servizio: 
    ```
    sudo systemctl start bulk-<blk_id>.service
    ```
    
  - controlla che funzioni, sia come status:
    ```
    sudo systemctl status bulk-<blk_id>.service
    ```
    sia caricando un file nel percorso prestabilito.
    
    Se qualcosa non dovesse funzionare, controllare ancora lo status del servizio. 
    In generale, se il codice funziona una volta terminato lo sviluppo, è probabile che il problema nasca da permessi non corretti 
    per uno dei due percorsi `public/bulk/...` o `samba`.
    
  - una volta accertato che tutto funzioni a dovere, abilitare il servizio all'avvio dell'OS:
    ```
    sudo systemctl enable bulk-<blk_id>.service
    ```
    
Alcuni comandi utili con i servizi Linux (da eseguirsi come utente *admin*)

- la lista dei servizi:
  ```
  sudo systemctl --type=service --state=running
  ```
