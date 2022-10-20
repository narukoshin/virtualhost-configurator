#!/bin/bash

# checking for root
if (( ! $(id -u) == 0)); then
    echo "Please run this script as root"
    exit
fi

apache_path=/etc/apache2
nginx_path=/etc/nginx

echo "Before we begin setting up the apache2 virtual host, we need you to specify the name of conf"
echo -n "Please type the name of conf: (eg. narukoshin.me): "
read conf_name

echo -n "Are you configuring Apache2 alongside with Nginx? (y/n): "
read nginx

# geting the document root
echo -n "Please type document root: "
read root

# creating a folder if it doesn't exist'
if [[ ! -d "${root}" ]]; then
    mkdir -p $root && echo "New folder created: $root."
fi

# asking for more folders to create
echo -n "You want to create more folders like logs, ssl? (y/n): "
read additional_folder_consent

# checking for the answer
# if answer is yes, then we will create those folders
if [[ "${additional_folder_consent}" == "y" ]]; then
    # asking to input path where the folders will be created
    echo -n "Please type the path where the folders will be created: "
    read additional_folder_path
    if [[ -d "$additional_folder_path" ]]; then
        # moving to this folder to create folders.
        cd $additional_folder_path
        mkdir logs ssl && echo "Folders successfuly created."
    fi

    # asking prompt for activating SSL
    echo -n "Do you want to enable SSL? (y/n): "
    read ssl_enabled

    if [[ "$ssl_enabled" == "y" ]]; then
        # asking for public key path
        echo -n "Please type the filename of public key: "
        read ssl_public_key
        # asking for private key path
        echo -n "Please type the filename of private key: "
        read ssl_private_key
        # creating public and private key files
        cd $additional_folder_path/ssl
        touch $ssl_public_key $ssl_private_key && echo "$ssl_public_key and $ssl_private_key were successfuly created at $additional_folder_path/ssl"
    fi
fi

# asking for the server name
echo -n "Please type server name (eg. localhost): "
read server_name

# asking for the alias
echo -n "Please type server alias (eg. www.localhost) (leave empty if none): "
read server_alias

# asking for the server admin email
echo -n "Please type the email of server admin (eg. admin@localhost): "
read server_admin

# asking for the port where's server hosted on
echo -n "Please type the port on which your apache2 server is running on (eg. 80): "
read apache_server_port

if [[ "$nginx" == "y" ]]; then
    echo -n "Please type the port on which your nginx server is running on (eg. 80): "
    read nginx_server_port
    if [[ "$apache_server_port" == "$nginx_server_port" ]]; then
        echo "Nginx and Apache2 can't run on the same port"
        exit
    fi
fi

# starting to build a virtualhost
apache_writer=$apache_path/sites-available/$conf_name.conf
nginx_writer=$nginx_path/sites-available/$conf_name

# checking if the apache config already exists
if [[ -d "apache_writer" ]]; then
    # deleting the file
    rm -f "$apache_writer"
fi

if [[ "$nginx" == "y" ]]; then
    # checking if the nginx config already exists
    if [[ -d "nginx_writer" ]]; then
        # deleting the file
        rm -f "$nginx_writer"
    fi
    # creating a new file
    touch $nginx_writer
    # writing the config
    echo "server {" > $nginx_writer
    echo "      # Basic Configuration" >> $nginx_writer
    if [[ "$ssl_enabled" == "y" ]]; then
        if [[ -d "$additional_folder_path/ssl" ]]; then
            echo "      listen $nginx_server_port ssl http2;" >> $nginx_writer
            echo "      listen [::]:$nginx_server_port ssl http2;" >> $nginx_writer
            echo "" >> $nginx_writer
            echo "      # SSL Configuration" >> $nginx_writer
            echo "      ssl_certificate $additional_folder_path/ssl/$ssl_public_key;" >> $nginx_writer
            echo "      ssl_certificate $additional_folder_path/ssl/$ssl_private_key;" >> $nginx_writer
            echo "      ssl_verify_client on;" >> $nginx_writer
        fi
    else
        echo "      listen $nginx_server_port;" >> $nginx_writer
        echo "      listen [::]:$nginx_server_port;" >> $nginx_writer
    fi
    if [[ -d "$additional_folder_path/logs" ]]; then
        echo "" >> $nginx_writer
        echo "      # Log File Configuration" >> $nginx_writer
        echo "      access_log $additional_folder_path/logs/access.log;" >> $nginx_writer
        echo "      error_log $additional_folder_path/logs/error.log;" >> $nginx_writer
    fi
    echo "" >> $nginx_writer
    echo "      proxy_redirect off;" >> $nginx_writer
    echo "      proxy_set_header X-Real-IP \$remote_addr;" >> $nginx_writer
    echo "      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> $nginx_writer
    echo "      proxy_set_header Host \$http_host;" >> $nginx_writer
    echo ""
    echo "      location / {" >> $nginx_writer
    if [[ "$ssl_enabled" == "y" ]]; then
        echo "          proxy_pass https://127.0.0.1:$apache_server_port;" >> $nginx_writer
    else
        echo "          proxy_pass http://127.0.0.1:$apache_server_port;" >> $nginx_writer
    fi
    echo "      }" >> $nginx_writer
    echo "}" >> $nginx_writer
fi

# creating a new file
touch $apache_writer

# writing the config
echo "<VirtualHost *:$apache_server_port>" > $apache_writer
echo "      # Basic Configuration" >> $apache_writer
echo "      ServerName $server_name" >> $apache_writer
# checkng if the alis is not empty
if [[ ! "$server_alias" == "" ]]; then
    echo "      ServerAlias $server_alias" >> $apache_writer
fi
echo "      ServerAdmin $server_admin" >> $apache_writer
echo "      DocumentRoot $root" >> $apache_writer

if [[ "$ssl_enabled" == "y" ]]; then
    if [[ -d "$additional_folder_path/ssl" ]]; then
        echo "      # SSL Configuration" >> $apache_writer
        echo "      SSLEngine On" >> $apache_writer
        echo "      SSLCertificateFile $additional_folder_path/ssl/$ssl_public_key" >> $apache_writer
        echo "      SSLCertificateKeyFile $additional_folder_path/ssl/$ssl_private_key" >> $apache_writer
    fi
fi

echo "</VirtualHost>" >> $apache_writer

# setting up proper and secure permissions
chown www-data:www-data -R $root
chmod 644 $root

if [[ -d "$additional_folder_path" ]]; then
    chown www-data:www-data -R $additional_folder_path
    # making ssl keys to be read only
    chmod 444 -R $additional_folder_path/ssl

    # adding only a read/write access for owner to the logs folder.
    chmod 600 $additional_folder_path/logs
fi

# activating nginx config
if [[ "$nginx" == "y" ]]; then
    echo "Activating Nginx config file"
    ln $nginx_path/sites-available/$conf_name $nginx_path/sites-enabled/$conf_name
fi

# trying to enable the config
a2ensite $conf_name

# reloading the apache2
systemctl reload apache2