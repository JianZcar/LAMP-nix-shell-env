[global]
error_log = ${ROOT_DIR}/.config/php/php-fpm.error.log
pid = ${ROOT_DIR}/.config/php/php-fpm.pid

[www]
listen = ${ROOT_DIR}/.config/php/php-fpm.sock
listen.owner = ${USER}
listen.group = ${USER}
listen.mode = 0660

pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3

php_admin_value[include_path] =  ${ROOT_DIR}/.config/php/php.ini

php_admin_value[error_log] = ${ROOT_DIR}/.config/php/php-fpm.www.error.log
php_admin_flag[log_errors] = on
