# strohhalm-kleiderausgabe backend

## Deployment

To deploy the backend, first create a folder

```bash
mkdir -p strohhalm-kleiderausgabe && cd strohhalm-kleiderausgabe
```

You then have 2 options to deploy the app.

### Option 1: Deploy with native binary

This method is faster, but do not use it if you are not familiar with system administration.

```bash
curl -L -o server \
    https://github.com/ngl16647/strohhalm-kleiderausgabe/releases/latest/download/backend-ubuntu && \
    chmod +x server && \
    ./server > server.log 2>&1 &
```

Once deployed, you can always run

```bash
./server > server.log 2>&1 &
```

to start the backend again. Make sure the previous instance is stopped before starting a new one.

### Option 2: Deploy with Docker

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

### After deployment

The server generate an API key when started for the first time, something like `1BLK-XVGG-56OW-H29T`. Note down your key and enter it to your frontend privately. Check the config file `config.yml` if you forget your key.

You can optionally restrict access to important files.

```bash
chmod 600 config.yml data.db server.log
```

## HTTPS

The server does not use HTTPS by default.

To enable HTTPS, create a TLS certificate and store it in the folder `strohhalm-kleiderausgabe/cert` (create this folder first if it does not exist), then adjust the configuration in `config.yml`.

For developers or internal usage, you can create a self-signed TLS certificate with the following command. This certificate expires in 1000 years so remember to generate a new one by then.

```bash
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 365000 -nodes -subj "/CN=<domain_name>"
```

`<domain_name>` can also be `localhost`.

You can optionally restrict access to important data:

```bash
chmod 600 config.yml data.db
```

## Maintenance

### Data

All data is stored in the file `data.db` and can be accessed internally using `sqlite3`. `sqlite3` can be installed with most package managers, for example:

```bash
sudo apt update && sudo apt install sqlite3
```

After installing, you can start your SQL query by 

```bash
sqlite3 data.db
``` 

You can backup your data by copying the file `data.db`.

### Log

When deployed with native binary, the log is store in file `server.log`.

When deployed with Docker, you can check the log with 

```bash
docker logs strohhalm-kleiderausgabe-backend | less
```

## Development

### Setup

Install Go version 1.24.4 or higher from [go.dev](https://go.dev/).

I recommend using VSCode for development. Use `Run and Debug` tag on the left to run the backend in development.

To build the backend, run `go build .`

### Flags

The backend binary can take multiple flags. Use `--help` to learn what they do. For example:

```bash
backend.exe --help
```

If you have Go environment, you can also do:

```bash
go run main.go --help
``` 

Notably the flag `--docs` prints out the endpoint documentation.

### Structure

There are currently 5 packages.

- **db:** Database layer. Handles direct communication with database.
- **routes:** Route layer. Uses database layer and handles API calls.
- **middlewares:** Middlewares. Handles logging and authorization.
- **cfg:** Configuration and flag parsing.
- **tests:** Casual testing. Experimental, no standardized unit tests yet.

### Actions

We currently have 3 GitHub Actions for building the app, configured in `.github/workflows`.
You can run them manually in the `Action` tag on the GitHub page. This makes it easier to share your build artifacts with teammates.

When you push a tag to `main` branch (see [Git-Tags](https://git-scm.com/book/en/v2/Git-Basics-Tagging)), all actions run and a new release page appears.
