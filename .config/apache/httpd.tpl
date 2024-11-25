ServerRoot ${SERVER_ROOT}
Listen ${SERVER_PORT}

LoadModule proxy_module modules/mod_proxy.so 
LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so

LoadModule mpm_prefork_module modules/mod_mpm_prefork.so
# LoadModule mpm_worker_module modules/mod_mpm_worker.so
# LoadModule mpm_event_module /path/to/modules/mod_mpm_event.so


LoadModule dir_module modules/mod_dir.so
LoadModule authz_core_module modules/mod_authz_core.so
LoadModule unixd_module modules/mod_unixd.so
#LoadModule log_config_module modules/mod_log_config.so

Define ROOT ${ROOT_DIR}
Include ${ROOT_DIR}/.config/apache/sites/*.conf 

ServerName localhost

ErrorLog "${ROOT_DIR}/.config/apache/error.log"
PidFile "${ROOT_DIR}/.config/apache/httpd.pid"

User ${USER}
Group ${USER}
