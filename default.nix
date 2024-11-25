{ pkgs ? import <nixpkgs> {}}:

let
  pwd = builtins.getEnv "PWD"; # Get the current working directory
in
pkgs.mkShell {
  buildInputs = [
    pkgs.apacheHttpd
    pkgs.mariadb
    pkgs.php
    pkgs.gettext
  ];


  shellHook = ''
    echo "LAMP stack environment loaded."
    echo "Apache available at $(which httpd)"
    echo "MariaDB available at $(which mysqld)"
    echo "PHP version $(php --version | head -n 1)"
    
    export SERVER_ROOT="${pkgs.apacheHttpd}"
    export SERVER_PORT=8080
    export ROOT_DIR=$PWD
    export USER=$(whoami)
    export PHP_FPM_SOCKET=$PWD/.config/php/php-fpm.sock
    envsubst < $PWD/.config/apache/httpd.tpl > $PWD/.config/apache/httpd.conf
    envsubst < $PWD/.config/php/php-fpm.tpl > $PWD/.config/php/php-fpm.conf 

    httpd -f $PWD/.config/apache/httpd.conf
    [ -f $PWD/.config/php/php-fpm.pid ] && kill $(cat $PWD/.config/php/php-fpm.pid)
    php-fpm -y $PWD/.config/php/php-fpm.conf -c $PWD/.config/php/php.ini -F &
    PHP_FPM_PID=$!
    sleep 1
    echo "Apache started with PID $APACHE_PID"

    MYSQL_BASEDIR=${pkgs.mariadb}
    MYSQL_HOME="$PWD/.config/mysql"
    MYSQL_DATADIR="$MYSQL_HOME/data"
    export MYSQL_UNIX_PORT="$MYSQL_HOME/mysql.sock"
    MYSQL_PID_FILE="$MYSQL_HOME/mysql.pid"
    alias mysql='mysql -u root'

    if [ ! -d "$MYSQL_HOME" ]; then
      # Make sure to use normal authentication method otherwise we can only
      # connect with unix account. But users do not actually exists in nix.
      mysql_install_db --no-defaults --auth-root-authentication-method=normal \
        --datadir="$MYSQL_DATADIR" --basedir="$MYSQL_BASEDIR" \
        --pid-file="$MYSQL_PID_FILE"
    fi

    # Starts the daemon
    # - Don't load mariadb global defaults in /etc with `--no-defaults`
    # - Disable networking with `--skip-networking` and only use the socket so 
    #   multiple instances can run at once
    mysqld --no-defaults --datadir="$MYSQL_DATADIR" --pid-file="$MYSQL_PID_FILE" \
    --socket="$MYSQL_UNIX_PORT" --bind-address=127.0.0.1 2> "$MYSQL_HOME/mysql.log" &
    MYSQL_PID=$!

    finish()
    {
      httpd -f $PWD/.config/apache/httpd.conf -k stop
      kill $PHP_FPM_PID
      mysqladmin -u root --socket="$MYSQL_UNIX_PORT" shutdown
    }
    trap finish EXIT SIGHUP SIGINT SIGTERM
  '';
}
