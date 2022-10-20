#!/bin/bash

# checking for root
if (( ! $(id -u) == 0)); then
    echo "Please run this script as root"
    exit
fi

# # geting the document root
# echo -n "Please type document root: "
# read root

# # creating a folder if it doesn't exist'
# if [[ ! -d "${root}" ]]; then
#     mkdir -p $root && echo "New folder created: $root."
# fi

# # asking for more folders to create
# echo -n "You want to create more folders like logs, ssl? (y/n): "
# read additional_folder_consent

# # checking for the answer
# # if answer is yes, then we will create those folders
# if [[ "${additional_folder_consent}" == "y" ]]; then
#     # asking to input path where the folders will be created
#     echo -n "Please type the path where the folders will be created: "
#     read additional_folder_path
#     if [[ -d "$additional_folder_path" ]]; then
#         # moving to this folder to create folders.
#         cd $additional_folder_path
#         mkdir logs ssl && echo "Folders successfuly created."
#     fi    
# fi

# # asking for the server name
# echo -n "Please type server name (eg. localhost): "
# read server_name

# # asking for the alias
# echo -n "Please type server alias (eg. www.localhost) (leave empty if none): "
# read server_alias

# # asking for the server admin email
# echo -n "Please type the email of server admin (eg. admin@localhost): "
# read server_admin

# asking for the port where's server hosted on
echo -n "Please type the port on which your server is running on (eg. 80): "
read server_port

# starting to build a virtualhost
echo "<VirtualHost \"*:$server_port\">"