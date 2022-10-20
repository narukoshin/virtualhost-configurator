#!/bin/bash

# checking for root
if (( ! $(id -u) == 0)); then
    echo "Please run this script as root"
    exit
fi

apache_path=/etc/apache2

echo "Before we begin setting up the apache2 virtual host, we need you to specify the name of conf"
echo -n "Please type the name of conf: (eg. narukoshin.conf): "
read conf_name

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
    echo -n "Do you want to enable SSL? (y/n)"
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
echo -n "Please type the port on which your server is running on (eg. 80): "
read server_port

# starting to build a virtualhost
file_to_write=$apache_path/sites-available/$conf_name
touch $file_to_write
echo "<VirtualHost \"*:$server_port\">" > $file_to_write
echo "      # Basic Configuration" >> $file_to_write
echo "      ServerName $server_name" >> $file_to_write
# checkng if the alis is not empty
if [[ ! "$server_alias" == "" ]]; then
    echo "      ServerAlias $server_alias" >> $file_to_write
fi
echo "      ServerAdmin $server_admin" >> $file_to_write
echo "      DocumentRoot $root" >> $file_to_write

if [[ "$ssl_enabled" == "y" ]]; then
    if [[ -d "$additional_folder_path/ssl" ]]; then
        echo "      # SSL Configuration" >> $file_to_write
        echo "      SSLEngine On" >> $file_to_write
        echo "      SSLCertificateFile $additional_folder_path/ssl/$ssl_public_key" >> $file_to_write
        echo "      SSLCertificateKeyFile $additional_folder_path/ssl/$ssl_private_key" >> $file_to_write
    fi
fi

echo "</VirtualHost>" >> $file_to_write