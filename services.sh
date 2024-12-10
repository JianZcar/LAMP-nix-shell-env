#!/usr/bin/env bash

# Paths to configuration and PID files
APACHE_CONF="$PWD/.config/apache/httpd.conf"
PHP_FPM_PID="$PWD/.config/php/php-fpm.pid"
MYSQL_PID_FILE="$PWD/.config/mysql/mysql.pid"
MYSQL_SOCKET="$PWD/.config/mysql/mysql.sock"

# Functions for managing services
start_apache() { echo "Starting Apache..."; httpd -f "$APACHE_CONF"; }
stop_apache() { echo "Stopping Apache..."; httpd -f "$APACHE_CONF" -k stop; }
restart_apache() { stop_apache; sleep 1; start_apache; }

start_php_fpm() { echo "Starting PHP-FPM..."; php-fpm -y "$PWD/.config/php/php-fpm.conf" -c "$PWD/.config/php/php.ini" -F & echo $! > "$PHP_FPM_PID"; }
stop_php_fpm() { echo "Stopping PHP-FPM..."; [ -f "$PHP_FPM_PID" ] && kill "$(cat "$PHP_FPM_PID")" && rm -f "$PHP_FPM_PID" || echo "PHP-FPM is not running."; }
restart_php_fpm() { stop_php_fpm; sleep 1; start_php_fpm; }

start_mysql() { echo "Starting MySQL..."; mysqld --no-defaults --datadir="$PWD/.config/mysql/data" --pid-file="$MYSQL_PID_FILE" --socket="$MYSQL_SOCKET" --bind-address=0.0.0.0 --user=root 2> "$PWD/.config/mysql/mysql.log" & echo $! > "$MYSQL_PID_FILE"; }
stop_mysql() { echo "Stopping MySQL..."; [ -f "$MYSQL_PID_FILE" ] && mysqladmin -u root --socket="$MYSQL_SOCKET" shutdown && rm -f "$MYSQL_PID_FILE" || echo "MySQL is not running."; }
restart_mysql() { stop_mysql; sleep 1; start_mysql; }

# Menu functions
menu_service() {
    echo "Select a service:"
    echo "1) Apache"
    echo "2) PHP-FPM"
    echo "3) MySQL"
    echo "4) Exit"
    echo "-------------------"
    read -rp "Choose a service: " service_choice
}

menu_action() {
    echo "Select an action for $1:"
    echo "1) Start"
    echo "2) Stop"
    echo "3) Restart"
    echo "4) Back"
    echo "-------------------"
    read -rp "Choose an action: " action_choice
}

# Main loop
while true; do
    menu_service
    case $service_choice in
        1) selected_service="Apache"; manage_service="apache";;
        2) selected_service="PHP-FPM"; manage_service="php_fpm";;
        3) selected_service="MySQL"; manage_service="mysql";;
        4) echo "Exiting..."; break ;;
        *) echo "Invalid service. Try again."; continue ;;
    esac

    while true; do
        menu_action "$selected_service"
        case $action_choice in
            1) "start_$manage_service" ;;
            2) "stop_$manage_service" ;;
            3) "restart_$manage_service" ;;
            4) break ;;
            *) echo "Invalid action. Try again." ;;
        esac
        sleep 1
    done
done
