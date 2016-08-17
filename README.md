# tklx/mysql - SQL database
[![CircleCI](https://circleci.com/gh/tklx/mysql.svg?style=shield)](https://circleci.com/gh/tklx/mysql)

MySQL is an open-source relational database management system (RDBMS). In July 2013, it was the world's second most widely used RDBMS, and the most widely used open-source client-server model RDBMS. MySQL is a popular choice of database for use in web applications, and is a central component of the widely used LAMP open-source web application software stack.

## Features

- Based on the super slim [tklx/base][base] (Debian GNU/Linux).
- MySQL installed from Debian.
- Uses [tini][tini] for zombie reaping and signal forwarding.
- Includes ``USER mysql`` to restrict the privileges of mysqld.
- Includes ``VOLUME /var/lib/mysql`` for database persistence.
- Includes ``EXPOSE 3306``, so standard container linking will make it
  automatically available to the linked containers.

## Usage

Note: If there is no database initialized when the container starts, then a default database will be created. The container will not accept incoming connections until initialization completes. This may cause issues when using automation tools such as `docker-compose`, which start several containers simultaneously.

### Start a MySQL instance and connect to it from an application

```console
$ docker run --name some-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d tklx/mysql
$ docker run --name some-app --link some-mysql:mysql -d application-that-uses-mysql
```

### Run with a host-local datadir (not recommended)

```console
$ chown -R 999:999 /my/own/datadir
$ docker run --name some-mysql -v /my/own/datadir:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d tklx/mysql
```

### Connect to MySQL from the MySQL command line client

```console
$ docker run -it --link some-mysql:mysql --rm tklx/mysql sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'
```

More information about the MySQL command line client can be found in the [MySQL documentation](http://dev.mysql.com/doc/en/mysql.html)

### Using a custom MySQL configuration

```console
$ docker run --name some-mysql -v /my/custom/conf.d/path:/etc/mysql/conf.d -e MYSQL_ROOT_PASSWORD=my-secret-pw -d tklx/mysql
```

Note that users on host systems with SELinux enabled may see issues with this. The current workaround is to assign the relevant SELinux policy type to the new config file so that the container will be allowed to mount it:

```console
$ chcon -Rt svirt_sandbox_file_t /my/custom/conf.d/path
```

### Creating database dumps

```console
$ docker exec some-mysql sh -c 'exec mysqldump --all-databases -uroot -p"$MYSQL_ROOT_PASSWORD"' > /some/path/on/your/host/all-databases.sql
```

### Environment Variables

Note: any pre-existing database in the datadir will always be left untouched on container startup.

#### `MYSQL_ROOT_PASSWORD`

This variable is mandatory and specifies the password that will be set for the MySQL `root` superuser account.

#### `MYSQL_DATABASE`

This variable is optional and allows to specify the name of a database to be created on image startup. If a user/password was supplied (see below) then that user will be granted superuser access ([corresponding to `GRANT ALL`][mysql-users]) to this database.

#### `MYSQL_USER`, `MYSQL_PASSWORD`

These variables are optional, used in conjunction to create a new user and to set that user's password. This user will be granted superuser permissions for the database specified by the `MYSQL_DATABASE` variable. Both variables are required for a user to be created.

#### `MYSQL_ALLOW_EMPTY_PASSWORD`

This is an optional variable. Set to `yes` to allow the container to be started with a blank password for the root user. *NOTE*: Setting this variable to `yes` is not recommended unless you really know what you are doing, since this will leave your MySQL instance completely unprotected, allowing anyone to gain complete superuser access.

#### `MYSQL_ONETIME_PASSWORD`

Sets the root (*not* the user specified in `MYSQL_USER`!) user as expired once init is complete, forcing a password change on first login.

### Tips

```console
# interactive root shell
$ docker run --rm -it -u root tklx/mysql /bin/bash

# server options
$ docker run -it --rm tklx/mysql --verbose --help

# client options
$ docker run -it --rm tklx/mysql mysql --verbose --help
```

## Automated builds

The [Docker image](https://hub.docker.com/r/tklx/mysql/) is built, tested and pushed by [CircleCI](https://circleci.com/gh/tklx/mysql) from source hosted on [GitHub](https://github.com/tklx/mysql).

* Tag: ``x.y.z`` refers to a [release](https://github.com/tklx/mysql/releases) (recommended).
* Tag: ``latest`` refers to the master branch.

## Status

Currently on major version zero (0.y.z). Per [Semantic Versioning][semver],
major version zero is for initial development, and should not be considered
stable. Anything may change at any time.

## Issue Tracker

TKLX uses a central [issue tracker][tracker] on GitHub for reporting and
tracking of bugs, issues and feature requests.

[mysql]: http://www.mysql.com
[mysql-users]: http://dev.mysql.com/doc/en/adding-users.html
[base]: https://github.com/tklx/base
[tini]: https://github.com/krallin/tini
[semver]: http://semver.org/
[tracker]: https://github.com/tklx/tracker/issues

