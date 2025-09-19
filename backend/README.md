# strohhalm-kleiderausgabe backend

## Deployment

To deploy with Docker, run `docker run -p 8080:8080 royjxu/strohhalm-kleiderausgabe`.

To deploy with native binary, run

```bash
$ mkdir -p strohhalm-kleiderausgabe && cd strohhalm-kleiderausgabe && \
    curl -L -o server \
    https://github.com/ngl16647/strohhalm-kleiderausgabe/releases/latest/download/backend-ubuntu && \
    chmod +x server && \
    ./server
```

**Important:** Deployment with native binary is only possible when the GitHub repository is public.

The server generate an API key when started for the first time. Copy this key to your frontend privately.