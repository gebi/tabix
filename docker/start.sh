#!/usr/bin/env bash
if [ ! -z "$PASSWORD" ]; then
  sh -c "echo -n '$USER:$(openssl passwd -crypt $PASSWORD)\n' >> /etc/nginx/.htpasswd"
else
  mv -f $APP_HOME/default_no_pass $DEFAULT
fi
CONN=""
if [ ! -z "$CH_NAME" ]; then
   CONN+="window.global_tabix_default_settings.name=\"${CH_NAME}\";"
fi
if [ -z "$CH_HOST" ]; then
    if [ ! -z "$CH_RESOLVE_HOST" ]; then
        host_="$(dig +short $CH_RESOLVE_HOST)"
        if [ ! -z "$host_" ]; then
            con_str_="${CH_RESOLVE_PROTO}${host_}${CH_RESOLVE_PORT}"
            echo "Success: resolved host \"${CH_RESOLVE_HOST}\" using connection string: \"${con_str_}\""
            CONN+="window.global_tabix_default_settings.host=\"${con_str_}\";"
        else
            echo "Error: could not resolve host: ${CH_RESOLVE_HOST}"
        fi
    fi
else
   CONN+="window.global_tabix_default_settings.host=\"${CH_HOST}\";"
fi
if [ ! -z "$CH_PASSWORD" ]; then
   CONN+="window.global_tabix_default_settings.password=\"${CH_PASSWORD}\";"
fi
if [ ! -z "$CH_LOGIN" ]; then
   CONN+="window.global_tabix_default_settings.login=\"${CH_LOGIN}\";"
fi
if [ ! -z "$CH_PARAMS" ]; then
   CONN+="window.global_tabix_default_settings.params=\"${CH_PARAMS}\";"
fi
if [ ! -z "$CONN" ]; then
  INDEX=$(cat /var/www/html/index.html)
  # Insert the connection string at the start of index.html if it does not already exist.
  if [[ $INDEX != *"window.global_tabix_default_settings"* ]]; then
    CONN="<script>window.global_tabix_default_settings={};${CONN}</script>"
    # Use simple bash replacement to avoid escaping complexity.
    INDEX=${INDEX/<head>/<head>$CONN}
    echo $INDEX > /var/www/html/index.html
  fi
fi
nginx -g "daemon off;"
