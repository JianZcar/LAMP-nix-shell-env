# LAMP Stack Development Environment

This README provides an overview of the LAMP (Linux, Apache, MySQL, PHP) stack development environment configured using Nix. The environment is set up to facilitate web development with Apache HTTP Server, MariaDB, and PHP.

## Prerequisites

- [Nix](https://nixos.org/download.html) package manager installed on your system.

## Getting Started

To enter the LAMP stack development environment, navigate to the directory containing the `shell.nix` file and run:

```bash
nix-shell
```

This command will load the environment and install the necessary packages.

## Environment Configuration

The following packages are included in the development environment:

- `apacheHttpd`: The Apache HTTP Server.
- `mariadb`: The MariaDB database server.
- `php`: The PHP programming language.
- `gettext`: A library for internationalization.

### Shell Hook

Upon entering the shell, the following actions are performed:

1. **Environment Variables**:
   - `SERVER_ROOT`: Path to the Apache HTTP Server.
   - `SERVER_PORT`: Set to `8080`.
   - `ROOT_DIR`: Current working directory.
   - `USER`: Current user.
   - `PHP_FPM_SOCKET`: Path to the PHP-FPM socket.

2. **Configuration Files**:
   - The Apache and PHP-FPM configuration files are generated using `envsubst` to substitute environment variables in the templates located in `.config/apache/httpd.tpl` and `.config/php/php-fpm.tpl`.

3. **Starting Services**:
   - Apache HTTP Server is started with the generated configuration.
   - PHP-FPM is started in the background.
   - MariaDB is initialized and started with a socket connection.

### Service Management

The following services are managed within the shell:

- **Apache HTTP Server**: Started with the command:
  ```bash
  httpd -f $PWD/.config/apache/httpd.conf
  ```

- **PHP-FPM**: Started with the command:
  ```bash
  php-fpm -y $PWD/.config/php/php-fpm.conf -c $PWD/.config/php/php.ini -F &
  ```

- **MariaDB**: Initialized and started with the command:
  ```bash
  mysqld --no-defaults --datadir="$MYSQL_DATADIR" --pid-file="$MYSQL_PID_FILE" --socket="$MYSQL_UNIX_PORT" --bind-address=127.0.0.1 &
  ```

### Cleanup

When exiting the shell, the following cleanup actions are performed:

- Apache HTTP Server is stopped.
- PHP-FPM is terminated.
- MariaDB is shut down gracefully.

## Notes

- Ensure that the `.config` directory contains the necessary configuration templates for Apache and PHP-FPM.
- The MariaDB installation will create a data directory if it does not already exist.

## Troubleshooting

If you encounter issues starting the services, check the log files located in the `.config/mysql` directory for MariaDB and the console output for Apache and PHP-FPM.

## Usage

Feel free to use and modify this project as you see fit!
