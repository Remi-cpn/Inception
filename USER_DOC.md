# User Documentation

This document explains how to use the Inception stack once it is deployed: what it provides,
how to start and stop it, how to access it, where the credentials live, and how to check that
everything is running correctly. For installation and development details, see
[DEV_DOC.md](DEV_DOC.md).

## What the stack provides

The project exposes a single WordPress website, reachable at `https://rcompain.42.fr`. Behind
that single address, three services work together:

| Service   | Role                                                              |
|-----------|--------------------------------------------------------------------|
| NGINX     | Only entry point of the infrastructure, serves the site over HTTPS (port 443, TLSv1.2/TLSv1.3) |
| WordPress | The website itself (content management system), rendered through php-fpm |
| MariaDB   | Stores the WordPress content (pages, posts, users) in a database  |

None of these services are reachable directly from outside the virtual machine except NGINX.

## Starting and stopping the project

All commands are run from the root of the repository, on the virtual machine.

```bash
make        # builds the images (if needed) and starts all the containers
```

```bash
make down   # stops and removes the containers, keeps the data
```

```bash
make clean  # stops the containers and deletes the Docker volumes (database + site files)
```

```bash
make fclean # same as clean, and also deletes /home/rcompain/data
```

```bash
make re     # equivalent to "make clean" followed by "make"
```

## Accessing the website and the administration panel

Before the first access, `rcompain.42.fr` must resolve to the virtual machine's IP address.
On the VM itself, this is usually done by adding a line to `/etc/hosts`:

```
127.0.0.1   rcompain.42.fr
```

Once the stack is running:

- **Website:** `https://rcompain.42.fr`
- **Administration panel:** `https://rcompain.42.fr/wp-admin`

The browser will warn about the certificate because it is self-signed (generated locally for
the project, not issued by a public certificate authority). This warning is expected and can
be safely bypassed for this project.

## Locating and managing credentials

All credentials are stored as environment variables in `srcs/.env`, a file that is not
versioned in git (it is listed in `.gitignore`). It is created from the
`srcs/.env.template` file, which lists every required variable without any value.

The `.env` file defines:

- `MYSQL_ROOT_PASSWORD`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_DATABASE` — used by MariaDB
  and by WordPress to connect to its database.
- `WP_ADMIN_USER`, `WP_ADMIN_PASSWORD`, `WP_ADMIN_EMAIL` — the WordPress administrator
  account, created automatically on first install.
- `WP_USER`, `WP_USER_EMAIL`, `WP_USER_PASSWORD` — a second, non-administrator WordPress
  account, also created automatically on first install.

To change a password, edit `srcs/.env` and recreate the stack with `make re` (note: this
deletes the existing database and site files, since the WordPress installation only runs
once, on an empty volume).

## Checking that the services are running correctly

```bash
make ps
```

This lists the three containers (`nginx`, `mariadb`, `wordpress`) and their status. All three
should be `Up`.

```bash
make logs
```

This prints the logs of every service, useful to check that WordPress connected to the
database correctly and that NGINX started without errors.

To check a single service:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

If a container keeps restarting, `docker logs <name>` will show the error that causes it to
exit; `docker ps -a` shows the restart count and the last exit status.
