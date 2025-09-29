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
    docker run -d \
        --name strohhalm-kleiderausgabe-backend \
        --restart unless-stopped \
        -v $(pwd)/data.db:/app/data.db \
        -v $(pwd)/config.yml:/app/config.yml \
        -v $(pwd)/cert:/app/cert \
        -p 8080:8080 \
        royjxu/strohhalm-kleiderausgabe:latest
```

The server generate an API key when started for the first time, something like `1BLK-XVGG-56OW-H29T`. Note down your key and enter it to your frontend privately. Check the config file `config.yml` if you forget your key.

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

All data is stored in the file `data.db` and can be accessed internally using `sqlite3`. `sqlite3` can be installed with most package managers, for example:

```bash
sudo apt update && sudo apt install sqlite3
```

After installing, you can start your SQL query by 

```bash
sqlite3 data.db
``` 

You can backup your data by copying the file `data.db`.
