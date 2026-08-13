# Inception

*This project has been created as part of the 42 curriculum by rcompain.*

## Description

Inception is a system administration project. The goal is to build a small, self-contained web
infrastructure using Docker, with every image built from scratch (no pre-built images from
Docker Hub except the base Alpine/Debian layer).

The stack is composed of three services running in three dedicated containers:

- **NGINX**, configured with TLSv1.2/TLSv1.3, acting as the single entry point of the
  infrastructure (port 443).
- **WordPress** with php-fpm, without any web server bundled inside the container.
- **MariaDB**, serving as the database for WordPress, without any web server either.

The containers communicate through a dedicated Docker network and share two persistent
named volumes: one for the WordPress database, one for the WordPress site files.

## Instructions

### Prerequisites

- A Linux virtual machine with Docker and Docker Compose installed.
- A `srcs/.env` file filled from `srcs/.env.template` (see [DEV_DOC.md](DEV_DOC.md)).
- An entry in `/etc/hosts` pointing `rcompain.42.fr` to `127.0.0.1`.

### Build and run

```bash
make            # builds the images and starts the stack in the background
```

Other available targets:

```bash
make down       # stops and removes the containers
make clean      # stops the stack and removes the Docker volumes
make fclean     # clean + removes /home/rcompain/data
make re         # clean + up
make logs       # shows the logs of every service
make ps         # shows the status of every container
```

Full details are available in [USER_DOC.md](USER_DOC.md) (usage) and
[DEV_DOC.md](DEV_DOC.md) (setup and development).

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose file reference](https://docs.docker.com/compose/compose-file/)
- [Docker volumes documentation](https://docs.docker.com/storage/volumes/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress CLI (wp-cli) documentation](https://developer.wordpress.org/cli/commands/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [Debian package documentation (mariadb-server, php-fpm, nginx)](https://packages.debian.org/)

### AI usage

An AI assistant (Claude) was used during this project for the following tasks:

- Reviewing the existing Dockerfiles, `docker-compose.yml`, and shell scripts against the
  subject's requirements, to spot gaps and configuration mistakes (for example, the missing
  `image:` names and the MariaDB restart issue described below).
- Drafting this README and the `USER_DOC.md` / `DEV_DOC.md` files from the actual project
  configuration.
- Preparing a personal revision document listing the commands and concepts needed for the
  defense.

The AI did not write the Dockerfiles, the shell scripts, or the `docker-compose.yml` — those
were written and configured manually. Every suggestion coming from the AI review was read,
understood, and only applied after being checked against the subject and, where relevant,
tested or discussed with a peer, in line with the project's AI usage guidelines.

## Project description: Docker usage and design choices

### Sources layout

```
srcs/
├── docker-compose.yml
├── .env                     # not versioned, built from .env.template
└── requirements/
    ├── nginx/
    ├── wordpress/
    └── mariadb/
```

Each service under `srcs/requirements/` has its own `Dockerfile`, its own configuration
files (`conf/`), and its own startup script (`tools/`). Every image is built from
`debian:bookworm` (the penultimate stable Debian release), with only the packages strictly
required for the service installed on top. No `latest` tag is used anywhere.

Each container starts through an `ENTRYPOINT` script that prepares the required runtime
directories and permissions, then hands off execution to the main process (`nginx`,
`php-fpm8.2`, `mariadbd`) using `exec`, so that process becomes PID 1. No infinite-loop
placeholder command (`tail -f`, `sleep infinity`, `while true`) is used to keep the
containers alive — the containers stay up because their main process is a real, long-running
daemon.

### Virtual Machines vs Docker

A virtual machine virtualizes an entire hardware stack and runs a full guest operating
system on top of a hypervisor, which makes it heavy to boot and resource-hungry. A Docker
container shares the host machine's kernel and only isolates the process, filesystem, and
network at the OS level, which makes it much lighter and faster to start. In this project,
the VM is only used as the host system on which Docker itself runs; each service (NGINX,
WordPress, MariaDB) then runs as its own lightweight container instead of its own VM.

### Secrets vs Environment Variables

Environment variables (`.env`, `env_file:`) are simple to use and are read directly by the
application, but they can leak more easily: they show up in `docker inspect`, in process
listings inside the container, and in some logs. Docker secrets are mounted as files inside
the container (usually under `/run/secrets/`) and are not exposed through `docker inspect`
or environment listings, which makes them the safer option for actual credentials. This
project currently relies on environment variables loaded from a non-versioned `.env` file
for simplicity; migrating the database and WordPress passwords to Docker secrets is the
main security improvement identified for this project.

### Docker Network vs Host Network

With `network: host`, a container shares the host's network stack directly: there is no
isolation, and the container can bind any port on the host machine. It is explicitly
forbidden by the subject. This project instead defines a dedicated bridge network
(`inception`) in `docker-compose.yml`. Containers on this network can reach each other by
service name (for example, WordPress connects to `mariadb`, NGINX proxies to `wordpress:9000`),
while staying isolated from the host network. Only NGINX publishes a port to the host
(443), which keeps a single, controlled entry point into the infrastructure.

### Docker Volumes vs Bind Mounts

A bind mount maps an arbitrary host path directly into a container; it depends on the host's
filesystem layout and is managed outside of Docker. A named volume is created and managed by
Docker itself, referenced by name in `docker-compose.yml`, and does not depend on knowing an
absolute host path in advance. The subject requires named volumes rather than bind mounts,
while also requiring the data to physically live under `/home/rcompain/data`. This project
satisfies both constraints by declaring named volumes (`wordpress`, `mariadb`) with the
`local` driver and `driver_opts` pointing at that path — Docker still manages them as named
volumes (referenced by name, listed by `docker volume ls`, etc.), but their data is stored at
the required location on the host.
