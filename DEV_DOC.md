# Developer Documentation

This document explains how to set up, build, and manage the Inception project as a
developer. For usage instructions once the stack is running, see [USER_DOC.md](USER_DOC.md).

## Prerequisites

- A Linux virtual machine (this project must run inside a VM).
- Docker Engine and the Docker Compose plugin installed.
- Root/sudo access on the VM (needed to create `/home/rcompain/data` and to run
  `make fclean`).
- `rcompain.42.fr` resolving to the VM's own IP address (an entry in `/etc/hosts` is
  enough for local evaluation).

## Repository layout

```
.
├── Makefile
└── srcs/
    ├── docker-compose.yml
    ├── .env.template        # list of required variables, no values
    ├── .env                 # actual values, not versioned (see below)
    └── requirements/
        ├── nginx/
        │   ├── Dockerfile
        │   └── conf/nginx.conf
        ├── wordpress/
        │   ├── Dockerfile
        │   ├── conf/www.conf
        │   └── tools/init_wordpress.sh
        └── mariadb/
            ├── Dockerfile
            ├── conf/50-server.cnf
            └── tools/
                ├── init_mariadb.sh
                └── init.sql.template
```

## Setting up the environment from scratch

1. Copy the template and fill in real values:

   ```bash
   cp srcs/.env.template srcs/.env
   ```

2. Edit `srcs/.env` and set every variable:

   - `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_ROOT_PASSWORD`
   - `DOMAIN_NAME` (`rcompain.42.fr`), `SITE_TITLE`
   - `WP_ADMIN_USER`, `WP_ADMIN_PASSWORD`, `WP_ADMIN_EMAIL` — **`WP_ADMIN_USER` must not
     contain `admin` or `administrator` (in any case)**, this is checked during evaluation.
   - `WP_USER`, `WP_USER_EMAIL`, `WP_USER_PASSWORD` — the second, non-administrator account.

   `srcs/.env` is listed in `.gitignore` and must never be committed.

3. Make sure `rcompain.42.fr` resolves locally, for example by adding to `/etc/hosts`:

   ```
   127.0.0.1   rcompain.42.fr
   ```

## Building and launching with the Makefile

The `Makefile` at the repository root drives everything through `docker compose -f
srcs/docker-compose.yml`.

```bash
make            # same as "make up": creates /home/rcompain/data,
                # then runs "docker compose up -d --build"
make down       # docker compose down (containers removed, volumes kept)
make clean      # docker compose down -v (containers and volumes removed)
make fclean     # make clean + sudo rm -rf /home/rcompain/data
make re         # make clean + make up
make logs       # docker compose logs
make ps         # docker compose ps
```

`make fclean` uses `sudo`, since the MariaDB data directory is owned by the `mysql` user
inside the container (root-equivalent on the host bind path); it may prompt for a password.

## Useful Docker Compose / Docker commands

```bash
# Rebuild a single service after changing its Dockerfile or scripts
docker compose -f srcs/docker-compose.yml up -d --build wordpress

# Follow the logs of one service
docker compose -f srcs/docker-compose.yml logs -f mariadb

# Open a shell inside a running container
docker exec -it wordpress bash
docker exec -it mariadb bash

# List containers, images, volumes, networks
docker ps -a
docker images
docker volume ls
docker network ls

# Inspect where a named volume actually stores its data on the host
docker volume inspect srcs_mariadb
docker volume inspect srcs_wordpress
```

## Data storage and persistence

Two Docker named volumes are declared in `srcs/docker-compose.yml`:

- `mariadb` → mounted at `/var/lib/mysql` inside the MariaDB container, holds the WordPress
  database.
- `wordpress` → mounted at `/var/www/html` inside the WordPress and NGINX containers, holds
  the WordPress installation (core files, themes, plugins, uploads).

Both volumes use the `local` driver with `driver_opts` (`type: none`, `o: bind`) pointing to
`/home/rcompain/data/mariadb` and `/home/rcompain/data/wordpress` on the host. This satisfies
the project requirement of storing the data under `/home/rcompain/data` while keeping them as
genuine Docker named volumes (created and referenced by name, visible with `docker volume
ls`), rather than plain bind mounts declared directly in the service's `volumes:` section.

Because the data lives in these volumes rather than in the containers themselves, `make down`
and even a full host reboot do not erase the WordPress site or its database: only `make
clean` / `make fclean` (or a manual `docker compose down -v`) removes them.

### Known limitation

The MariaDB entrypoint script ([init_mariadb.sh](srcs/requirements/mariadb/tools/init_mariadb.sh))
only performs the first-run database/user creation once, by checking whether
`/var/lib/mysql/wordpress` already exists. On a container recreation with data already
present in the volume (for example after `make down && make`, or a VM reboot followed by
relaunching Docker Compose), make sure the entrypoint does not try to re-apply
`--init-file` against a temporary file that no longer exists in the new container's
filesystem — regenerate it or drop the flag when the database is already initialized.
