service-storages
=============
[<img src="https://img.shields.io/docker/cloud/build/paperwork/service-storages.svg?style=for-the-badge"/>](https://hub.docker.com/r/paperwork/service-storages)

Paperwork Storages Service

## Prerequisites

### Docker

Get [Docker Desktop](https://www.docker.com/products/docker-desktop).

### Elixir/Erlang

On MacOS using [brew](https://brew.sh):

```bash
% brew install elixir
```

## Building

Fetching all dependencies:

```bash
% mix deps.get
```

Compiling:

```bash
% mix compile
```

## Running

In order to run this service, we need to install the dependencies it has:

```bash
$ # on macOS
$ brew install imagemagick
$ # on Ubuntu Linux
$ apt-get install imagemagick
```

For all other operating systems, check the [ImageMagick site](https://imagemagick.org/script/download.php).

Atfer that, we can initialize the service this service depends on.

First, we need a database and an object store. Let's run MongoDB and Minio on Docker:

```bash
% docker run -it --rm --name mongodb -p 27017:27017 mongo:latest
```

```bash
% docker run -it --rm --name minio -e 'MINIO_ACCESS_KEY=root' -e 'MINIO_SECRET_KEY=roooooot' -p 9000:9000 minio/minio:latest server /data
```

Second, we need to run [service-gatekeeper](https://github.com/paperwork/service-gatekeeper). Please refer to its documentation.

Then we can run this service from within this cloned repository:

```bash
% iex -S mix
```
