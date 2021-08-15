# Fetch

## Setup

Using docker, install with following command.

```
docker build -t fetch .
```

## How to Use

Asume that you will be running from docker container.
Simple call the command and pass some urls.

### Fetch

This command will fetch given webpages from urls.

```
docker run -v $PWD:/app-data fetch [ARRAY OF URL WITH HTTP/HTTPS SCHEMA]
```

The fetched webpage will be stored in `$PWD/[THE URL WITHOUT SCHEMA]/index.html`

Example:

```
./fetch https://warungpintar.co.id/juragan-grosir/ https://www.ruby-lang.org/en/news/
```

From above example, we will have the fetched webpage in `$PWD/warungpintar.co.id/juragan-grosir/index.html` and `$PWD/www.ruby-lang.org/en/news/index.html`.

### Load Metadata

This command will print the metadata of the fetched site,
if it had not already fetched the it will returns file not found error.

```
docker run -v $PWD:/app-data fetch --metadata [ARRAY OF URL WITH HTTP/HTTPS SCHEMA]
```
