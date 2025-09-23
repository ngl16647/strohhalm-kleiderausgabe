# strohhalm-kleiderausgabe backend

## Deployment

To deploy the backend, first create a folder

```bash
mkdir -p strohhalm-kleiderausgabe && cd strohhalm-kleiderausgabe
```

You then have 2 options to deploy the app.

- **Deploy with native binary (recommended when using Ubuntu):**

```bash
curl -L -o server \
    https://github.com/ngl16647/strohhalm-kleiderausgabe/releases/latest/download/backend-ubuntu && \
    chmod +x server && \
    ./server
```

- **Deploy with Docker:**

```bash
touch data.db config.yml && \
    docker run \
        --name strohhalm-kleiderausgabe-backend \
        -v $(pwd)/data.db:/app/data.db \
        -v $(pwd)/config.yml:/app/config.yml \
        -p 8080:8080 \
        royjxu/strohhalm-kleiderausgabe
```

The server generate an API key when started for the first time, something like `1BLK-XVGG-56OW-H29T`. Note down your key and enter it to your frontend privately. Check the config file `config.yml` if you forget your key.

## HTTPS

The server does not use HTTPS by default. You can configure this in `config.yml`.

For developers or internal usage, you can create a self-signed TLS certificate with the following command. This certificate expires in 10 years.

```bash
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 3650 -nodes -subj "/CN=<domain_name>"
```

`domain_name` can also be `localhost`.

## Maintenance

All data is stored in the file `data.db` and can be accessed internally using `sqlite3`. `sqlite3` can be installed with most package managers, for example:

```bash
sudo apt update && sudo apt install sqlite3
```

After installing, you can start your SQL query by 

```bash
sqlite3 data.db
``` 

You can backup data by copying the file `data.db`.
