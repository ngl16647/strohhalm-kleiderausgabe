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

## Wartung

Alle Daten werden in der Datei `data.db` gespeichert und können intern mit `sqlite3` abgerufen werden. `sqlite3` kann mit den meisten Paketmanagern installiert werden, z. B.:

```bash
sudo apt update && sudo apt install sqlite3
```

Danach kannst du Abfragen starten mit:

```bash
sqlite3 data.db
``` 

Ein Backup der Daten erstellst du, indem du die Datei `data.db` kopierst.

## Entwicklung

### Setup

Installiere Go in Version 1.24.4 oder höher von [go.dev](https://go.dev/).

Ich empfehle VSCode für die Entwicklung. Verwende das Run & Debug-Panel auf der linken Seite, um das Backend während der Entwicklung zu starten.

Um das Backend zu erstellen, führe `go build .` aus.

### Flags

Das Backend-Binary kann mit verschiedenen Flags gestartet werden. Nutze `--help`, um alle verfügbaren Optionen zu sehen, z. B.:

```bash
backend.exe --help
```

Alternativ kannst du das Projekt direkt mit Go starten:

```bash
go run main.go --help
```

Besonders nützlich: Das Flag `--docs` gibt die Dokumentation aller Endpunkte aus.

### Struktur

Es gibt aktuell 5 Packages:

- **db:** Datenbank-Schicht. Kommuniziert direkt mit der Datenbank.
- **routes:** Route-Schicht. Nutzt die Datenbank-Schicht und verarbeitet API-Aufrufe.
- **middlewares:** Middlewares für Logging und Autorisierung.
- **cfg:** Konfiguration und Flag-Auswertung.
- **tests:** Lockere Tests. Es gibt derzeit keine standardisierten Unit-Tests.

### Actions

Wir nutzen aktuell 3 GitHub Actions zum Bauen der App, konfiguriert in .github/workflows.
Du kannst sie manuell im Actions-Tab auf GitHub ausführen, um Build-Artefakte mit Teammitgliedern zu teilen.

Wenn du einen Tag in den main-Branch pusht (siehe [Git-Tags](https://git-scm.com/book/en/v2/Git-Basics-Tagging)), werden alle Actions ausgeführt und eine neue Release-Seite erstellt.
