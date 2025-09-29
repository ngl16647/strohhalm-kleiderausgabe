# strohhalm-kleiderausgabe backend

## Deployment

Um das Backend zu starten, lege zuerst einen Ordner an:

```bash
mkdir -p strohhalm-kleiderausgabe && cd strohhalm-kleiderausgabe
```

Es gibt danach zwei Möglichkeiten, die Anwendung bereitzustellen:

- **Mit einer nativen Binary (empfohlen unter Ubuntu):**

```bash
curl -L -o server \
    https://github.com/ngl16647/strohhalm-kleiderausgabe/releases/latest/download/backend-ubuntu && \
    chmod +x server && \
    ./server
```

- **Mit Docker:**

```bash
touch data.db config.yml && \
    docker run -d \
        --name strohhalm-kleiderausgabe-backend \
        --restart unless-stopped \
        -v $(pwd)/data.db:/app/data.db \
        -v $(pwd)/config.yml:/app/config.yml \
        -v $(pwd)/cert:/app/cert \
        -p 8080:8080 \
        royjxu/strohhalm-kleiderausgabe:latest
```

Beim ersten Start erzeugt der Server automatisch einen API-Key, z. B. `1BLK-XVGG-56OW-H29T`.
Notiere dir den Schlüssel und trage ihn im Frontend ein. Falls du ihn vergisst, kannst du ihn in der Datei `config.yml` nachsehen.

Optional kannst du die Zugriffsrechte für wichtige Dateien einschränken:

```bash
chmod 600 config.yml data.db
```

## HTTPS

Standardmäßig läuft der Server ohne HTTPS.

Um HTTPS zu aktivieren, lege ein TLS-Zertifikat in den Ordner `strohhalm-kleiderausgabe/cert` (Ordner ggf. anlegen) und passe die Konfiguration in `config.yml` an.

Für Entwicklung oder interne Nutzung kannst du mit dem folgenden Befehl ein selbstsigniertes Zertifikat erstellen. Dieses Zertifikat läuft in 1000 Jahren ab. Stell dir sicher, bis dahin ein neues zu erstellen.

```bash
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 365000 -nodes -subj "/CN=<domain_name>"
```
`<domain_name>` kann auch `localhost` sein.

## Maintenance

Alle Daten werden in der Datei `data.db` gespeichert und können intern mit `sqlite3` abgerufen werden. `sqlite3` kann mit den meisten Paketmanagern installiert werden, z. B.:

```bash
sudo apt update && sudo apt install sqlite3
```

Danach kannst du Abfragen starten mit:

```bash
sqlite3 data.db
``` 

Ein Backup der Daten erstellst du, indem du die Datei `data.db` kopierst.
