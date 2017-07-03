# Docker-haproxy
Containerized Load-Balancer: [haproxy](http://www.haproxy.org/)

HAProxy is the open source Load-balancer. It's a full HTTP / TLS / TCP reverse-proxy with many advanced features regarding load-balancing and HTTP processing.
This container embeds Lua scripting engine into HAProxy.

# Building the container

Clone this repository, go into the directory and run a command like: `docker build --tag haproxy --build-arg HAPROXY_VER=1.7 .`

It is mandatory to precise a version number for gdns through the argument **HAPROXY_VER**.

One can also use the docker-compose.yml file provided here: `docker-compose build`

# Using the container

## Normal usage

Use a command like this one:

  `docker run --detach --rm=true --volumes ./my-haproxy-config/:/etc/haproxy/ --name=haproxy --hostname=haproxy haproxy`

Or use docker-compose:

  `docker-compose up -d`

## Debugging

Use a command like this one:

  `docker run -it --rm=true --volumes ./my-haproxy-config/:/etc/haproxy/ --name=haproxy --hostname=haproxy --entrypoint=sh haproxy`

Or use docker-compose:

  `docker-compose up`

